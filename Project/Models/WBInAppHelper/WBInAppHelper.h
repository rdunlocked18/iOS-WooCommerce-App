//
//  WBInAppHelper.h
//  Werbary Kit
//
//  Created by Ivan Trufanov on 31.01.14.
//  Copyright (c) 2014 Werbary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^ActionBlock)(BOOL success, NSError *err);


@interface WBInAppHelper : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    NSArray *a_product_ids;
    NSArray *a_products;
    
    NSDictionary *d_purchased_cache;
    NSMutableDictionary *d_purchase_blocks;
    ActionBlock blockRestore;
    
    SKProductsRequest *productsReq;
    NSMutableDictionary *d_price_cache;
}


+ (void) setProductsList:(NSArray *)products;

+ (BOOL) isProductPaid:(NSString *)productId;

+ (void) payProduct:(NSString *)productId resBlock:(ActionBlock)block;
+ (void) restorePayments:(ActionBlock)block;

+ (NSString *) priceStringFromProductId:(NSString *)productId;
@end
