//
//  afGoogleMapsGeocodingWS.m
//  g2park
//
//  Created by adrien ferré on 20/05/11.
//  Copyright 2011 Ferré. All rights reserved.
//

#import "afGMapsGeocodingRequest.h"
#import "AddressComponent.h"

@implementation afGMapsGeocodingRequest

@synthesize reverseGeocoding, afDelegate,providedAddress,boundsP1,boundsP2,useBounds,providedCoordinates;

#pragma mark ------------------------------------------
#pragma mark ------ INIT
#pragma mark ------------------------------------------

+(id) request{
    return [[[self alloc] initDefault] autorelease];
}

-(id) initDefault{
    self = [super initDefault];
    
    if (self){
        [self setUserInfo: [NSDictionary dictionaryWithObject:@"geocoding" forKey:@"type"]];
        useBounds = NO;
        self.delegate = self;
    }
    
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ Helpers
#pragma mark ------------------------------------------

-(void) setTheAddress:(NSString *)taddress{
    reverseGeocoding = NO;
    self.providedAddress = taddress;
}

-(void) setLatitude:(double)lat andLongitude:(double)lng{
    reverseGeocoding = YES;
    providedCoordinates = CLLocationCoordinate2DMake(lat, lng);
}

-(void) setBoundsUpperLeft:(CGPoint) p1 downRight:(CGPoint)p2{
    useBounds = YES;
    self.boundsP1 = p1;
    self.boundsP2 = p2;
}

#pragma mark ------------------------------------------
#pragma mark ------ ASI HTTP OVERRIDES
#pragma mark ------------------------------------------

-(void) startAsynchronous{
    [self setURL:[self makeURL]];
    [super startAsynchronous];
}

-(void) startSynchronous{
    
    [self setURL:[self makeURL]];
    [super startSynchronous];
}

#pragma mark ------------------------------------------
#pragma mark ------ URL COMPUTING
#pragma mark ------------------------------------------

-(NSURL *) makeURL{
    NSString *rootURL = [super makeURLStringWithServicePrefix:GOOGLE_GEOCODING_API_PATH_COMPONENT];
    
    if (reverseGeocoding){
        //latlng to address
        rootURL = [rootURL stringByAppendingFormat:@"latlng=%@",[NSString stringWithFormat:@"%f,%f",providedCoordinates.latitude,providedCoordinates.longitude]];
    }
    else{
        //adress to latlng
        rootURL = [rootURL stringByAppendingFormat:@"address=%@",providedAddress];
    }
    
    //bounds
    if (useBounds){
        rootURL = [rootURL stringByAppendingFormat:@"&bounds=%d,%d|%d,%d",boundsP1.x ,boundsP1.y , boundsP2.x,boundsP2.y];
    }
    
    //region
    if (region != ccTLD_DEFAULT)
        rootURL = [rootURL stringByAppendingFormat:@"&region=%@",[afGoogleMapsAPIRequest regionCode:region]];
    
    //language
    if (language != LangDEFAULT)
        rootURL = [rootURL stringByAppendingFormat:@"&language=%@",[afGoogleMapsAPIRequest languageCode:language]];
    
    return [super finalizeURLString:rootURL];
}

#pragma mark ------------------------------------------
#pragma mark ------ ASI HTTP REQUEST DELEGATE FUNCTIONS
#pragma mark ------------------------------------------

-(void) request:(ASIHTTPRequest *)req didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    
}

-(void) request:(ASIHTTPRequest *)req willRedirectToURL:(NSURL *)newURL{
    
}

-(void) requestFailed:(ASIHTTPRequest *)req{
    if (WS_DEBUG) {
        NSLog(@"Request failed");
        NSLog(@"%@ %@",[[req error]localizedDescription], [[req error] localizedFailureReason]);
    }
    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWSFailed:withError:)]){
        [afDelegate afGeocodingWSFailed:self withError:[self error]];
    }
}

-(void) requestFinished:(ASIHTTPRequest *)req{
    
    if (WS_DEBUG) NSLog(@"Request finished %@",[req responseString]);
    
    SBJsonParser *json;
    NSError *jsonError;
    
    json = [ [ SBJsonParser new ] autorelease ];
    
    jsonResult = [[ json objectWithString:[req responseString] error:&jsonError ] copy];
    
    if (jsonResult == nil) {
        NSLog(@"Erreur lors de la lecture du code JSON (%@).", [ jsonError localizedDescription ]);
        
        NSError *err =  [self errorForService:@"Geocoding" type:@"JSON" status:nil];
        
        if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWSFailed:withError:)]){
            [afDelegate afGeocodingWSFailed:self withError:err];
        }
        return;
    } 
    else{
        //
        //ERROR CHECK
        //
        NSString *topLevelStatus = [jsonResult objectForKey:@"status"];
        if (![topLevelStatus isEqualToString:@"OK"]){
            if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWSFailed:withError:)]){
                NSError *err =  [self errorForService:@"Geocoding" type:@"GM" status:topLevelStatus];
        
                [afDelegate afGeocodingWSFailed:self withError:err];
            }
            return;
        }
        
        //
        //DATA PROCESSING
        //
        
        //Now we need to obtain our coordinates
        NSArray *gmResults  = [jsonResult objectForKey:@"results"];
        
        if (WS_DEBUG)    
            NSLog(@"%d objects", [gmResults count]);
        
        if ([gmResults count] > 1){
            int i;
            NSMutableArray *custResults = [NSMutableArray arrayWithCapacity:[gmResults count]];
            
            for (i = 0 ; i<[gmResults count] ; i++){
                NSDictionary *jsonResultDico = [gmResults objectAtIndex:i];
                
                Result *result = [Result parseJsonDico:jsonResultDico];
                [custResults addObject:result];   
            }
            
            if (reverseGeocoding){
                NSMutableArray *ar = [NSMutableArray arrayWithCapacity:[custResults count]];
                for (i = 0 ; i<[gmResults count] ; i++){
                    [ar addObject:((Result *)[custResults objectAtIndex:i]).formattedAddress];
                } 
                if (WS_DEBUG)
                    NSLog(@"Address: %@",ar);
                
                if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWS:gotMultipleAddresses:fromLatitude:andLongitude:)]){
                    
                    [afDelegate afGeocodingWS:self gotMultipleAddresses:ar fromLatitude:providedCoordinates.latitude andLongitude:providedCoordinates.longitude];
                }
            }
            else{
                
                if (WS_DEBUG)
                    NSLog(@"Latitude - Longitude: %f %f",((Result *)[custResults objectAtIndex:0]).geometry.location.latitude, ((Result *)[custResults objectAtIndex:0]).geometry.location.longitude);
                
                if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWS:gotCoordinates:fromAddress:)]){
                    [afDelegate afGeocodingWS:self gotCoordinates:((Result *)[custResults objectAtIndex:0]).geometry.location fromAddress:providedAddress];
                }
            } 
        }
        else if ([gmResults count] == 1){
            Result *result = [Result parseJsonDico:[gmResults objectAtIndex:0]];
            
            if (reverseGeocoding){
                if (WS_DEBUG)
                    NSLog(@"Address: %@ ",result.formattedAddress);
                
                if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWS:gotAddress:fromLatitude:andLongitude:)]){
                    [afDelegate afGeocodingWS:self gotAddress:result.formattedAddress fromLatitude:providedCoordinates.latitude andLongitude:providedCoordinates.longitude];
                }
            }
            else{
                if (WS_DEBUG)
                    NSLog(@"Latitude - Longitude: %f %f",result.geometry.location.latitude, result.geometry.location.longitude);
                
                if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWS:gotCoordinates:fromAddress:)]){
                    [afDelegate afGeocodingWS:self gotCoordinates:result.geometry.location fromAddress:providedAddress];
                }
            } 
        }
        else {
            
        }
    }
}

-(void)requestRedirected:(ASIHTTPRequest *)req{
    
}

-(void) requestStarted:(ASIHTTPRequest *)req{
    if (WS_DEBUG) NSLog(@"Request started");
    
    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afGeocodingWSStarted:)]){
        [afDelegate afGeocodingWSStarted:self];
    }
}


-(void) dealloc{
    
    [providedAddress release];
    providedAddress = nil;
    
    [super dealloc];
}
@end

@implementation Result

@synthesize addressComponents,geometry,formattedAddress,types;

+(Result *)parseJsonDico:(NSDictionary *)result{
    
    Result *res = [[[Result alloc] init] autorelease];
    NSString *formattedAddress = [[result objectForKey:@"formatted_address"] copy];
    res.formattedAddress = formattedAddress;
    [formattedAddress release];
    
    NSArray *resultTypesStringArray = [result objectForKey:@"types"];
    NSMutableArray *resultsTypesArray = [NSMutableArray arrayWithCapacity:[resultTypesStringArray count]];
    NSArray *addressComponentsArray = [result objectForKey:@"address_components"];
    NSMutableArray *addressComponents = [NSMutableArray array];
    
    for (NSString *type in resultTypesStringArray){
        AddressComponentType addressType = [AddressComponent AddressComponentTypeFromString:type];
        NSNumber *addressTypeNumber = [NSNumber numberWithInt:addressType];
        [resultsTypesArray addObject:addressTypeNumber];
    }
    
    res.types = resultsTypesArray;
    
    for (NSDictionary *addressCompDico in addressComponentsArray){
        AddressComponent *addressComp = [AddressComponent parseJsonDico:addressCompDico];
        [addressComponents addObject:addressComp];
    }
    
    res.addressComponents = addressComponents;
    
    NSDictionary *geoDico = [result objectForKey:@"geometry"];
    
    Geometry *geometry = [Geometry parseJsonDico:geoDico];
    res.geometry = geometry;
   
    return res;
}

-(void) dealloc{
    
    [addressComponents release];
    addressComponents = nil;
    [geometry release];
    geometry = nil;
    [formattedAddress release];
    formattedAddress = nil;
    [types release];
    types = nil;
    
    [super dealloc];
}

@end
