
#import "RNSquarePos.h"
//Following have been added as the umbrella header file of SquarePointOfSaleSDK.h is no more shipped from upstream SquarePointOfSaleSDK
#import <SquarePointOfSaleSDK/SCCMoney.h>
#import <SquarePointOfSaleSDK/SCCAPIRequest.h>
#import <SquarePointOfSaleSDK/SCCAPIConnection.h>
#import <Foundation/Foundation.h>

@implementation RNSquarePos

NSString *applicationId;

RCT_EXPORT_METHOD(setApplicationId:(NSString *) _applicationId) {
    applicationId = _applicationId;
}

RCT_EXPORT_METHOD(
	startTransaction:(int)_amount 
	currency:(NSString *)currency 
	options:(NSDictionary *)options 
	callbackUrl:(NSString *)callbackUrl
	onError:(RCTResponseSenderBlock)onError
) {
	NSError *error;
	NSURL *const callbackURL = [NSURL URLWithString:callbackUrl];
	SCCMoney *const amount = [SCCMoney moneyWithAmountCents:_amount currencyCode:currency error:NULL];
	[SCCAPIRequest setApplicationID:applicationId]; //clientID property is deprecated. Instead per documentation applicationID property needs to be set.

	// notes
	NSString *notes = nil;
	if ([options objectForKey:@"note"]) {
		notes = [options objectForKey:@"note"];
	}

	// tenderTypes
	SCCAPIRequestTenderTypes tenderTypes = nil;
	SCCAPIRequestTenderTypes currType;
	NSArray *_tenderTypes = nil;
	NSString *tenderType;
	if ([options objectForKey:@"tenderTypes"]) {
		_tenderTypes = [options objectForKey:@"tenderTypes"];
		for (int i = 0; i < [_tenderTypes count]; i++) {
			tenderType = [_tenderTypes objectAtIndex:i];
			currType = nil;
			if ([tenderType isEqualToString:@"CASH"]) {
				currType = SCCAPIRequestTenderTypeCash;
			} else if ([tenderType isEqualToString:@"CARD"]) {
				currType = SCCAPIRequestTenderTypeCard;
			} else if ([tenderType isEqualToString:@"GIFT_CARD"]) {
				currType = SCCAPIRequestTenderTypeSquareGiftCard;
			} else if ([tenderType isEqualToString:@"CARD_ON_FILE"]) {
				currType = SCCAPIRequestTenderTypeCardOnFile;
			} else if ([tenderType isEqualToString:@"OTHER"]) {
				currType = SCCAPIRequestTenderTypeOther;
			}

			if (currType != nil) {
				if (tenderTypes == nil) {
					tenderTypes = currType;
				} else {
					tenderTypes = tenderTypes | currType;
				}
			}
		}
	}
	if (tenderTypes == nil) {
		tenderTypes = SCCAPIRequestTenderTypeAll;
	}

	// location id
	NSString *locationId = nil;
	if ([options objectForKey:@"locationId"]) {
		locationId = [options objectForKey:@"locationId"];
	}

	// autoreturn
	BOOL autoReturn = NO;
	if ([options objectForKey:@"returnAutomaticallyAfterPayment"]) {
		autoReturn = [options objectForKey:@"returnAutomaticallyAfterPayment"];
	}

	SCCAPIRequest *request = [SCCAPIRequest
														requestWithCallbackURL:callbackURL
														amount:amount
														userInfoString:nil
														locationID:locationId
														notes:notes
														customerID:nil
														supportedTenderTypes:tenderTypes
														clearsDefaultFees:NO
														returnsAutomaticallyAfterPayment:autoReturn
														disablesKeyedInCardEntry:NO
														skipsReceipt:NO
														error:&error];
	[SCCAPIConnection performRequest:request error:&error];
	if (error != nil) {
		onError(@[[NSNumber numberWithInt:[error code]], [error localizedDescription]]);
	}
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

@end
