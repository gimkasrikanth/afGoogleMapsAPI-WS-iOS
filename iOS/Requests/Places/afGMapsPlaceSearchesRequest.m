//
//  afGMapsPlaceSearchesRequest.m
//  afGMDemo
//
//  Created by adrien ferré on 01/10/11.
//  Copyright 2011 Ferré. All rights reserved.
//

#import "afGMapsPlaceSearchesRequest.h"

@implementation afGMapsPlaceSearchesRequest

@synthesize location,name,afDelegate,radius,types,htmlAttributions,places;


#pragma mark ------------------------------------------
#pragma mark ------ INIT
#pragma mark ------------------------------------------

+ (id) request{
    return [[[self alloc] initDefault] autorelease];
}

- (id) initDefault{
    
    self = [super initDefault];
    
    if (self){
        [self setUserInfo: [NSDictionary dictionaryWithObject:@"PlaceSearches" forKey:@"type"]];
        self.delegate = self;
    }
    
    return self;
}
#pragma mark ------------------------------------------
#pragma mark ------ URL COMPUTING
#pragma mark ------------------------------------------

-(NSURL *) makeURL{
    
    NSString *rootURL = [super makeURLStringWithServicePrefix:@"search"];
    
    //location
    rootURL = [rootURL stringByAppendingFormat:@"location=%f,%f",location.latitude,location.longitude];
    
    //radius
    rootURL = [rootURL stringByAppendingFormat:@"&radius=%f",radius];
    
    //radius
    if(types) 
        if ([types count] >0){
            int i = 0;
            rootURL = [rootURL stringByAppendingFormat:@"&types="];
            
            for (i = 0 ; i < [types count] ; i ++){
                NSString *type = [types objectAtIndex:i];
                if (i==[types count] - 1 ){
                    rootURL = [rootURL stringByAppendingFormat:@"%@",type];
                }
                else{
                    rootURL = [rootURL stringByAppendingFormat:@"%@|",type];
                    
                }
            }
        }
    
    //language
    if (language != LangDEFAULT){
        rootURL = [rootURL stringByAppendingFormat:@"&language=%@",[afGoogleMapsAPIRequest languageCode:language]];   
    }
    
    //name
    if (name) if (![name isEqualToString:@""])
        rootURL = [rootURL stringByAppendingFormat:@"&name=%@",name];
        
    return [super finalizeURLString:rootURL];
}

-(void) addTypeString:(NSString *) typeString{
    PlacesType1 type = [Place PlacesType1FromString:typeString];
    
    [self addTypeEnum:type];
}

-(void) addTypeEnum:(PlacesType1) type{
    if (!types) types = [[NSMutableArray alloc] init];
    
    if (type != PlacesType1Not_defined)
        [types addObject:[Place PlacesType1StringFromObjectType:type]];
    
}

#pragma mark ------------------------------------------
#pragma mark ------ ASI HTTP REQUEST Overrides
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
#pragma mark ------ ASI HTTP REQUEST Delegate functions
#pragma mark ------------------------------------------

-(void) request:(ASIHTTPRequest *)req didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    
}

-(void) request:(ASIHTTPRequest *)req willRedirectToURL:(NSURL *)newURL{
    
}

-(void) requestFailed:(ASIHTTPRequest *)req{
    if (WS_DEBUG) NSLog(@"Request failed");
    NSLog(@"%@ %@",[[req error]localizedDescription], [[req error] localizedFailureReason]);
    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afPlaceSearchesWSFailed:withError:)]){
        [afDelegate afPlaceSearchesWSFailed:self withError:[self error]];
    }
}

-(void) requestFinished:(ASIHTTPRequest *)req{
    
    if (WS_DEBUG) NSLog(@"Request finished with data %@",[req responseString]);
    
    SBJsonParser *json;
    NSError *jsonError;
    
    // Init JSON
    json = [ [ SBJsonParser new ] autorelease ];
    
    if (jsonResult != nil) {
        [jsonResult release];
        jsonResult = nil;
    }
    
    jsonResult = [[ json objectWithString:[req responseString] error:&jsonError ] copy];
    
    // Check if there is an error
    if (jsonResult == nil) {
        
        NSLog(@"Error when reading JSON (%@).", [ jsonError localizedDescription ]);
        
        NSError *err =  [self errorForService:@"Place Search" type:@"JSON" status:nil];
        
        if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afPlaceSearchesWSFailed:withError:)]){
            [afDelegate afPlaceSearchesWSFailed:self withError:err];
        }
        return;
    } else {
        NSString *status = [jsonResult objectForKey:@"status"];
        if (![status isEqualToString:@"OK"] ){
            
            NSError *err =  [self errorForService:@"Place Search" type:@"GM" status:status];
        
            if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afPlaceSearchesWSFailed:withError:)]){
                [afDelegate afPlaceSearchesWSFailed:self withError:err];
            }
            return;
        }
        NSArray *jsonPlaces = [jsonResult objectForKey:@"results"];
        places = [[NSMutableArray alloc] initWithCapacity:[jsonPlaces count]];
        for (NSDictionary *jsonDico in jsonPlaces){
            Place *place = [Place parseJsonDico:jsonDico];
            [places addObject:place];
        }
        
        htmlAttributions = [[jsonResult objectForKey:@"html_attributions"] copy];
        
        if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afPlaceSearchesWS:foundPlaces:htmlAttributions:)]){
            [afDelegate afPlaceSearchesWS:self foundPlaces:places htmlAttributions:htmlAttributions];
        }
    }
}

-(void)requestRedirected:(ASIHTTPRequest *)req{
    
}

-(void) requestStarted:(ASIHTTPRequest *)req{
    if (WS_DEBUG) NSLog(@"Request started");
    
    if (afDelegate!=NULL && [afDelegate respondsToSelector:@selector(afPlaceSearchesWSStarted:)]){
        [afDelegate afPlaceSearchesWSStarted:self];
    }
}

-(void) dealloc{
    
    afDelegate = nil;
    
    [name release];
    name = nil;
    
    [types release];
    types = nil;
    
    [super dealloc];
}

@end