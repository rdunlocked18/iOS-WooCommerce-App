//
//  WBInAppHelper.m
//  Kefir
//
//  Created by Иван Труфанов on 31.01.14.
//  Copyright (c) 2014 wit. All rights reserved.
//

#import "WBInAppHelper.h"
#import "NSData+AES256.h"

@implementation WBInAppHelper

static WBInAppHelper * sharedHelper = NULL;
+ (WBInAppHelper *) sharedHelper {
    if (!sharedHelper || sharedHelper == NULL) {
        sharedHelper = [WBInAppHelper new];
        sharedHelper->d_price_cache = [NSMutableDictionary new];
        [sharedHelper setup];
    }
    return sharedHelper;
}

#pragma mark -
#pragma mark - Public
+ (void) setProductsList:(NSArray *)products {
    [[WBInAppHelper sharedHelper] setProductsList:products];
}

+ (BOOL) isProductPaid:(NSString *)productId {
    return [[WBInAppHelper sharedHelper] isProductPaid:productId];
}

+ (void) payProduct:(NSString *)productId resBlock:(ActionBlock)block {
    [[WBInAppHelper sharedHelper] payProduct:productId resBlock:block];
}
+ (void) restorePayments:(ActionBlock)block {
    [[WBInAppHelper sharedHelper] restorePayments:block];
}

+ (NSString *) priceStringFromProductId:(NSString *)productId {
    return [[WBInAppHelper sharedHelper] priceStringFromProductId:productId];
}

#pragma mark -
#pragma mark - Private

#pragma mark Init
- (void) setup {
    d_purchase_blocks = [NSMutableDictionary new];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark Actions
- (void) setProductsList:(NSArray *)products {
    a_product_ids = [products copy];
    
    productsReq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:a_product_ids]];
    productsReq.delegate = self;
    [productsReq start];
}
- (void) payProduct:(NSString *)productId resBlock:(ActionBlock)block {
    ActionBlock copyBlock = (__bridge ActionBlock)Block_copy((__bridge void *)block);
    d_purchase_blocks[productId] = copyBlock;
    Block_release((__bridge void *)block);
    
    if (TARGET_IPHONE_SIMULATOR) {
        [self productPaid:productId];
        block(YES,nil);
        return;
    }
    
    SKProduct *product = [self productWithId:productId];
    if (!product) {
        block(NO,nil);//Add error
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    SKPaymentQueue *queue = [SKPaymentQueue defaultQueue];
    [queue addPayment:payment];
}
- (void) restorePayments:(ActionBlock)block {
    blockRestore = block;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark SKProductsRequestDelegate
- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    a_products = [response.products copy];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loaded_products_list" object:nil];
}
- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    
}

#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}
- (void) completeTransaction:(SKPaymentTransaction *)transaction {
    [self productPaid:transaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if (d_purchase_blocks[transaction.payment.productIdentifier]) {
        ActionBlock block = d_purchase_blocks[transaction.payment.productIdentifier];
        block(YES,nil);
    }
}
- (void) failedTransaction:(SKPaymentTransaction *)transaction {
    ActionBlock block = [self blockForProductId:transaction.payment.productIdentifier];
    if (block) {
        if (transaction.error.code != SKErrorPaymentCancelled) {
            block(NO,transaction.error);
        } else {
            block(NO,nil);
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void) restoreTransaction:(SKPaymentTransaction *)transaction {
    [self completeTransaction:transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (blockRestore) {
        blockRestore(NO,error);
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (blockRestore) {
        blockRestore(YES,nil);
    }
}


#pragma mark Saving/getting paid items
- (NSString *) priceStringFromProductId:(NSString *)productId {
    if (d_price_cache[productId]) {
        return d_price_cache[productId];
    } else {
        SKProduct *product = [[WBInAppHelper sharedHelper] productWithId:productId];
        if (!product) {
            d_price_cache[productId] = NSLocalizedString(@"Error", nil);
            return NSLocalizedString(@"Error", nil);
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:[product priceLocale]];
        
        NSString *str = [formatter stringFromNumber:[product price]];
        d_price_cache[productId] = str;
        return str;
    }
}
- (BOOL) isProductPaid:(NSString *)productId {
    if (!d_purchased_cache) {
        [self updateProductsCache];
    }
    if (d_purchased_cache[productId]) {
        return YES;
    }
    return NO;
}
- (void) productPaid:(NSString *)productId {
    NSArray *array = @[@"asff",@"fsd",@"fdsfs"];
    NSDictionary *dict = @{@"sdds":@"fs",@"dssf":@"ds",@"fsd":@"fsdf"};

    NSMutableDictionary *dataDict = [[self productsInfoDictionary] mutableCopy];
    if (!dataDict) {
        dataDict = [NSMutableDictionary new];
    }
    dataDict[productId] = @(YES);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
    data = [data AES256EncryptWithKey:[NSString stringWithFormat:@"%@%@%@%@%@%@",array[1],[dict allKeys][0],[dict allValues][2],array[2],array[0],[dict allKeys][1]]];
    [data writeToFile:[self productsPath] atomically:NO];
    
    [self updateProductsCache];
}
- (NSString *)productsPath {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingString:@"/data.ski"];
    return directory;
}
- (NSDictionary *) productsInfoDictionary {
    NSData *data = [NSData dataWithContentsOfFile:[self productsPath]];
    if (!data) {
        data = [NSData data];
    } else {
        NSArray *array = @[@"asff",@"fsd",@"fdsfs"];
        NSDictionary *dict = @{@"sdds":@"fs",@"dssf":@"ds",@"fsd":@"fsdf"};
        
        data = [data AES256DecryptWithKey:[NSString stringWithFormat:@"%@%@%@%@%@%@",array[1],[dict allKeys][0],[dict allValues][2],array[2],array[0],[dict allKeys][1]]];
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}
- (void) updateProductsCache {
    d_purchased_cache = [self productsInfoDictionary];
}

#pragma mark Helpers
- (ActionBlock) blockForProductId:(NSString *)idStr {
    return d_purchase_blocks[idStr];
}

- (SKProduct *) productWithId:(NSString *)idStr {
    for (SKProduct *product in a_products) {
        if ([product.productIdentifier isEqualToString:idStr]) {
            return product;
        }
    }
    return nil;
}
@end
