//
//  afGoogleMapsDistanceWS.m
//  g2park
//
//  Created by adrien ferré on 29/05/11.
//  Copyright 2011 Ferré. All rights reserved.
//

#import "afGMapsDistanceRequest.h"


@implementation afGMapsDistanceRequest

@synthesize afDelegate,origins,destinations,travelMode,avoidMode,unitsSystem;

#pragma mark ------------------------------------------
#pragma mark ------ INIT
#pragma mark ------------------------------------------


+(id) distanceRequest{
    return [[[self alloc] initDefault] autorelease];
}

-(id)initDefault{
    self = [super initDefault];
    
    if (self){
        
        self.travelMode = TravelModeDefault;
        self.avoidMode = AvoidModeNone;
        self.unitsSystem = UnitsDefault;
        
        [self setUserInfo: [NSDictionary dictionaryWithObject:@"distance" forKey:@"type"]];
        self.delegate = self;
        
    }
    
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ ASI HTTP REQUEST Overrides
#pragma mark ------------------------------------------

-(void) startAsynchronous{
    [self setURL:[self  makeURL]];
    [super startAsynchronous];
}

-(void) startSynchronous{
    
    [self setURL:[self  makeURL]];
    [super startSynchronous];
}

#pragma mark ------------------------------------------
#pragma mark ------ URL COMPUTING
#pragma mark ------------------------------------------

-(NSURL *)makeURL{
    
    NSMutableString *rootURL = [NSMutableString stringWithString: [self getURLString]];
    
    [rootURL appendFormat:@"%@",GOOGLE_DISTANCE_API_PATH_COMPONENT];
    
    switch (format) {
        case ReturnJSON:
        {
            [rootURL appendFormat:@"/json?"];
        }
            break;
        case ReturnXML:
        {
             [rootURL appendFormat:@"/xml?"];
        }
            break;
        default:
        {
            [rootURL appendFormat:@"/json?"];
        }
            break;
    }
    
    //origins
     [rootURL appendFormat:@"origins="];
    
    int i = 0;
    for (NSString *origin in origins) {
        NSString *str = [origin stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        i++;
        if([origin isEqualToString:@""]){
            
        }else if (i == [origins count])
            [rootURL appendFormat:@"%@",str];
        else
            [rootURL appendFormat:@"%@|",str];
    }
    
    //destinations
    [rootURL appendFormat:@"&destinations="];
    
    i = 0;
    for (NSString *dest in destinations) {
        NSString *str = [dest stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        i++;
        if([dest isEqualToString:@""]){
            
        }else if (i == [destinations count])
            [rootURL appendFormat:@"%@",str];
        else
           [rootURL appendFormat:@"%@|",str];
    }
    
    //mode
    if (travelMode != TravelModeDefault)
         [rootURL appendFormat:@"&mode=%@",[afGoogleMapsAPIRequest travelMode:travelMode]];
    
    //language
    if (language != LangDEFAULT)
        [rootURL appendFormat:@"&language=%@",[afGoogleMapsAPIRequest languageCode:language]];
    
    //avoid
    if (avoidMode != AvoidModeNone)
         [rootURL appendFormat:@"&avoid=%@",[afGoogleMapsAPIRequest avoidMode:avoidMode]];
    
    //units
    if (unitsSystem != UnitsDefault)
        switch (unitsSystem) {
            case UnitsImperial:
               [rootURL appendFormat:@"&units=imperial"];
                break;
                
            case UnitsMetric:
                [rootURL appendFormat:@"&units=metric"];
                break;
                
            default:
                break;
        }
    
    //sensor
    if (useSensor) 
       [rootURL appendFormat:@"&sensor=true"];
    else
        [rootURL appendFormat:@"&sensor=false"];
   //  [rootURL replaceOccurrencesOfString:@"|" withString:@"%7C" options:NSCaseInsensitiveSearch range:NSRangeFromString(rootURL)];
    
    NSString * finalURL = [rootURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  
    NSLog(@"URL IS %@",finalURL);  
   
    NSLog(@"NSURL IS %@",[NSURL URLWithString:finalURL]);
    
    return [NSURL URLWithString:finalURL];
    
}

#pragma mark ------------------------------------------
#pragma mark ------ ASI HTTP REQUEST Delegate functions
#pragma mark ------------------------------------------

-(void) request:(ASIHTTPRequest *)req didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    
}

-(void) request:(ASIHTTPRequest *)req willRedirectToURL:(NSURL *)newURL{
    
}

-(void) requestFailed:(ASIHTTPRequest *)req{
    if (WS_DEBUG) NSLog(@"Request failed");
    NSLog(@"%@ %@",[[req error]localizedDescription], [[req error] localizedFailureReason]);
    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afDistanceWSFailed:withError:)]){
        [afDelegate afDistanceWSFailed:self withError:[[self error] localizedDescription]];
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
    } else {
        
        /*
         OK indicates the response contains a valid result.
         INVALID_REQUEST indicates that the provided request was invalid.
         MAX_ELEMENTS_EXCEEDED indicates that the product of origins and destinations exceeds the per-query limit.
         OVER_QUERY_LIMIT indicates the service has received too many requests from your application within the allowed time period.
         REQUEST_DENIED indicates that the service denied use of the Distance Matrix service by your application.
         UNKNOWN_ERROR indicates a Distance Matrix request could not be processed due to a server error. The request may succeed if you try again.
         */
        
        NSString *topLevelStatus = [jsonResult objectForKey:@"status"];
        if ([topLevelStatus isEqualToString:@"OK"]){
            
        }
        else {
            if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afDistanceWSFailed:withError:)]){
                NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
                                                                              NSLocalizedString(@"GoogleMaps Distance Matrix API returned status code %@",@""),
                                                                              topLevelStatus]
                                                                      forKey:NSLocalizedDescriptionKey];
                
                [afDelegate afDistanceWSFailed:self withError:[NSError errorWithDomain:@"GoogleMaps Distance Matrix API Error" code:666 userInfo:errorInfo]];
            }
            return;
        }
        
        //ROW = ORIGIN
        //ROW 0 = ORIGIN = 0
        NSArray *returnedOrigins = [jsonResult objectForKey:@"origin_addresses"];
        NSArray *returnedDestinations = [jsonResult objectForKey:@"destination_addresses"];
        NSArray *rows = [jsonResult objectForKey:@"rows"];
        NSLog(@"ROWS COUNT %d",[rows count]);
        
        if([rows count] != [origins count]){
            if(WS_DEBUG) NSLog(@"rows count != origins count");
        }
        int i;
        
        for (i = 0 ; i < [rows count]; i++){
            NSLog(@"PARSING ROW %d",i);
            int j;
            NSString *providedOrigin = [origins objectAtIndex:i];
            NSString *returnedOrigin = [returnedOrigins objectAtIndex:i];
            
            NSDictionary *row = [rows objectAtIndex:i];
            
            //ELEMENT = DEST
            //ELEMENT 0 = DEST = 0
            NSArray *elements = [row objectForKey:@"elements"];
            
            for (j = 0 ; j < [elements count]; j++){
                NSLog(@"PARSING element %d",j);
                NSDictionary *childEle = [elements objectAtIndex:j];
                NSString *providedDest = [destinations objectAtIndex:j];
                NSString *returnedDest = [returnedDestinations objectAtIndex:j];
                
                /*
                 ELEMENT STATUS 
                 OK indicates the response contains a valid result.
                 NOT_FOUND indicates that the origin and/or destination of this pairing could not be geocoded.
                 ZERO_RESULTS indicates no route could be found between the origin and destination.
                 */
                NSString *elementStatus = [childEle objectForKey:@"status"];
                if ([elementStatus isEqualToString:@"OK"]){
                    
                    NSDictionary * distanceDico = [childEle objectForKey:@"distance"];
                    NSString *textDistance = [distanceDico objectForKey:@"text"];
                    NSNumber *valueDistance = [NSNumber numberWithDouble:[[distanceDico objectForKey:@"value"] doubleValue]];
                    NSDictionary * durationDico = [childEle objectForKey:@"duration"];
                    NSString *textDuration = [durationDico objectForKey:@"text"];
                    NSNumber *valueDuration = [NSNumber numberWithDouble:[[durationDico objectForKey:@"value"] doubleValue]];
                    
                    
                    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afDistanceWS:distance:origin:destination:unit:)]){
                        [afDelegate afDistanceWS:self distance:valueDistance origin:providedOrigin destination:providedDest unit:unitsSystem];
                    }
                    
                    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afDistanceWS:distance:textDistance:origin:returnedOrigin:destination:returnedDestination:duration:textDuration:unit:)]){
                        [afDelegate afDistanceWS:self distance:valueDistance textDistance:textDistance origin:providedOrigin returnedOrigin:returnedOrigin destination:providedDest returnedDestination:returnedDest duration: valueDuration textDuration:textDuration unit:unitsSystem];
                    }
                }
                else {
                    if( afDelegate !=NULL && [afDelegate respondsToSelector:@selector(afDistanceWS:origin:destination:failedWithError:)]){
                        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
                                                                                      NSLocalizedString(@"GoogleMaps Distance Matrix API returned status code %@",@""),
                                                                                      elementStatus]
                                                                              forKey:NSLocalizedDescriptionKey];
                        
                        [afDelegate afDistanceWS:self origin:providedOrigin destination:providedDest failedWithError:[NSError errorWithDomain:@"GoogleMaps Distance Matrix API Error" code:666 userInfo:errorInfo]];
                        
                    }
                }
            }
        }
        
        NSDictionary *dico = [rows objectAtIndex:0];
        
        
        //ELEMENT = DEST
        //ELEMENT 0 = DEST = 0
        NSArray *elements = [dico objectForKey:@"elements"];
        
        NSDictionary *childEle = [elements objectAtIndex:0];
        
        NSString *status = [childEle objectForKey:@"status"];
        if ([status isEqualToString:@"ZERO_RESULTS"] || [status isEqualToString:@"NOT_FOUND"]){
            
            if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afDistanceWSFailed:withError:)]){
                [afDelegate afDistanceWSFailed:self withError:status];
            }
        }
        else {
            NSDictionary *distanceDico = [childEle objectForKey:@"distance"];
            
            NSNumber *distance = [NSNumber numberWithDouble:[[distanceDico objectForKey:@"value"] doubleValue]];
            
            if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afDistanceWS:gotDistance:unit:)]){
                [afDelegate afDistanceWS:self gotDistance:distance unit:unitsSystem];
                
            }
        }
    }
}

-(void)requestRedirected:(ASIHTTPRequest *)req{
    
    if (WS_DEBUG) NSLog(@"Request redirected");
}

-(void) requestStarted:(ASIHTTPRequest *)req{
    if (WS_DEBUG) NSLog(@"Request started");
    
    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afDistanceWSStarted:)]){
        [afDelegate afDistanceWSStarted:self];
    }
}

-(void) dealloc{
    
    afDelegate = nil;
    [origins release];
    origins = nil;
    [destinations  release];
    destinations = nil;
    
    [super dealloc];
    
}

@end

