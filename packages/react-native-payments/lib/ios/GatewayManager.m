#import "GatewayManager.h"

#if __has_include(<Stripe/Stripe.h>)
#import <Stripe/Stripe.h>
#endif

#if __has_include(<BraintreeApplePay/BraintreeApplePay.h>)
#import <BraintreeApplePay/BraintreeApplePay.h>
#endif

#if __has_include("PKPaymentConverter.h")
#import "PKPaymentConverter.h"
#endif

#import "PKPaymentConverter.h"

@implementation GatewayManager

+ (NSArray *)getSupportedGateways
{
    NSMutableArray *supportedGateways = [NSMutableArray array];

#if __has_include(<Stripe/Stripe.h>)
    [supportedGateways addObject:@"stripe"];
#endif

#if __has_include(<BraintreeApplePay/BraintreeApplePay.h>)
    [supportedGateways addObject:@"braintree"];
#endif
    
#if __has_include("PKPaymentConverter.h")
    [supportedGateways addObject:@"cloudpayments"];
#endif

    return [supportedGateways copy];
}

- (void)configureGateway:(NSDictionary *_Nonnull)gatewayParameters
      merchantIdentifier:(NSString *_Nonnull)merchantId
{
#if __has_include(<Stripe/Stripe.h>)
    if ([gatewayParameters[@"gateway"] isEqualToString:@"stripe"]) {
        [self configureStripeGateway:gatewayParameters merchantIdentifier:merchantId];
    }
#endif

#if __has_include(<BraintreeApplePay/BraintreeApplePay.h>)
    if ([gatewayParameters[@"gateway"] isEqualToString:@"braintree"]) {
        [self configureBraintreeGateway:gatewayParameters];
    }
#endif
}

- (void)createTokenWithPayment:(PKPayment *_Nonnull)payment
                    completion:(void (^_Nullable)(NSString * _Nullable token, NSError * _Nullable error))completion
{
#if __has_include(<Stripe/Stripe.h>)
    [self createStripeTokenWithPayment:payment completion:completion];
#endif

#if __has_include(<BraintreeApplePay/BraintreeApplePay.h>)
    [self createBraintreeTokenWithPayment:payment completion:completion];
#endif
    
 #if __has_include("PKPaymentConverter.h")
    [self createCloudPaymentsTokenWithPayment:payment completion:completion];
 #endif
}

// Stripe
- (void)configureStripeGateway:(NSDictionary *_Nonnull)gatewayParameters
            merchantIdentifier:(NSString *_Nonnull)merchantId
{
#if __has_include(<Stripe/Stripe.h>)
    NSString *stripePublishableKey = gatewayParameters[@"stripe:publishableKey"];
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:stripePublishableKey];
    [[STPPaymentConfiguration sharedConfiguration] setAppleMerchantIdentifier:merchantId];
#endif
}

- (void)createStripeTokenWithPayment:(PKPayment *)payment completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion
{
#if __has_include(<Stripe/Stripe.h>)
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken * _Nullable token, NSError * _Nullable error)
    {
        if (error) {
            completion(nil, error);
        } else {
            completion(token.tokenId, nil);
        }
    }];
#endif
}

// Braintree
- (void)configureBraintreeGateway:(NSDictionary *_Nonnull)gatewayParameters
{
#if __has_include(<BraintreeApplePay/BraintreeApplePay.h>)
    NSString *braintreeTokenizationKey = gatewayParameters[@"braintree:tokenizationKey"];
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:braintreeTokenizationKey];
#endif
}

- (void)createBraintreeTokenWithPayment:(PKPayment *_Nonnull)payment
                    completion:(void (^_Nullable)(NSString * _Nullable token, NSError * _Nullable error))completion
{
#if __has_include(<BraintreeApplePay/BraintreeApplePay.h>)
    BTApplePayClient *applePayClient = [[BTApplePayClient alloc]
                                        initWithAPIClient:self.braintreeClient];

    [applePayClient tokenizeApplePayPayment:payment
                                 completion:^(BTApplePayCardNonce *tokenizedApplePayPayment,
                                              NSError *error)
    {


        if (error) {

            completion(nil, error);
        } else {

            completion(tokenizedApplePayPayment.nonce, nil);
        }
    }];
#endif
}

// Cloud Payments
- (void)configureCloudPaymentsGateway:(NSDictionary *_Nonnull)gatewayParameters
            merchantIdentifier:(NSString *_Nonnull)merchantId
{
#if __has_include("PKPaymentConverter.h")
#endif
}

- (void)createCloudPaymentsTokenWithPayment:(PKPayment *)payment completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion
{
#if __has_include("PKPaymentConverter.h")
    @try
    {
      // Attempt access to an empty array
      NSString *token = [PKPaymentConverter convertToString: payment];
      completion(token, nil);
    }
    @catch (NSException *exception)
    {
      // Print exception information
      NSLog( @"NSException caught" );
      NSLog( @"Name: %@", exception.name);
      NSLog( @"Reason: %@", exception.reason );
      completion(nil, nil);
    }
#endif
}

@end
