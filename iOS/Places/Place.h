//
//  Place.h
//  afGMDemo
//
//  Created by adrien ferré on 02/10/11.
//  Copyright 2011 Ferré. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geometry.h"
#import "afEnum.h"

enum {
    PlacesType1Accounting,
    PlacesType1Airport,
    PlacesType1Amusement_park,
    PlacesType1Aquarium,
    PlacesType1Art_gallery,
    PlacesType1Atm,
    PlacesType1Bakery,
    PlacesType1Bank,
    PlacesType1Bar,
    PlacesType1Beauty_salon,
    PlacesType1Bicycle_store,
    PlacesType1Book_store,
    PlacesType1Bowling_alley,
    PlacesType1Bus_station,
    PlacesType1Cafe,
    PlacesType1Campground,
    PlacesType1Car_dealer,
    PlacesType1Car_rental,
    PlacesType1Car_repair,
    PlacesType1Car_wash,
    PlacesType1Casino,
    PlacesType1Cemetery,
    PlacesType1Church,
    PlacesType1City_hall,
    PlacesType1Clothing_store,
    PlacesType1Convenience_store,
    PlacesType1Courthouse,
    PlacesType1Dentist,
    PlacesType1Department_store,
    PlacesType1Doctor,
    PlacesType1Electrician,
    PlacesType1Electronics_store,
    PlacesType1Embassy,
    PlacesType1Establishment,
    PlacesType1Finance,
    PlacesType1Fire_station,
    PlacesType1Florist,
    PlacesType1Food,
    PlacesType1Funeral_home,
    PlacesType1Furniture_store,
    PlacesType1Gas_station,
    PlacesType1General_contractor,
    PlacesType1Geocode,
    PlacesType1Grocery_or_supermarket,
    PlacesType1Gym,
    PlacesType1Hair_care,
    PlacesType1Hardware_store,
    PlacesType1Health,
    PlacesType1Hindu_temple,
    PlacesType1Home_goods_store,
    PlacesType1Hospital,
    PlacesType1Insurance_agency,
    PlacesType1Jewelry_store,
    PlacesType1Laundry,
    PlacesType1Lawyer,
    PlacesType1Library,
    PlacesType1Liquor_store,
    PlacesType1Local_government_office,
    PlacesType1Locksmith,
    PlacesType1Lodging,
    PlacesType1Meal_delivery,
    PlacesType1Meal_takeaway,
    PlacesType1Mosque,
    PlacesType1Movie_rental,
    PlacesType1Movie_theater,
    PlacesType1Moving_company,
    PlacesType1Museum,
    PlacesType1Night_club,
    PlacesType1Painter,
    PlacesType1Park,
    PlacesType1Parking,
    PlacesType1Pet_store,
    PlacesType1Pharmacy,
    PlacesType1Physiotherapist,
    PlacesType1Place_of_worship,
    PlacesType1Plumber,
    PlacesType1Police,
    PlacesType1Post_office,
    PlacesType1Real_estate_agency,
    PlacesType1Restaurant,
    PlacesType1Roofing_contractor,
    PlacesType1Rv_park,
    PlacesType1School,
    PlacesType1Shoe_store,
    PlacesType1Shopping_mall,
    PlacesType1Spa,
    PlacesType1Stadium,
    PlacesType1Storage,
    PlacesType1Store,
    PlacesType1Subway_station,
    PlacesType1Synagogue,
    PlacesType1Taxi_stand,
    PlacesType1Train_station,
    PlacesType1Travel_agency,
    PlacesType1University,
    PlacesType1Veterinary_care,
    PlacesType1Zoo,
    PlacesType1Not_defined
};
typedef NSInteger PlacesType1;

static NSString *PlacesType1AsStrings[] = {[PlacesType1Accounting] = @"Accounting",
    [PlacesType1Airport] = @"Airport",
    [PlacesType1Amusement_park] = @"Amusement park",
    [PlacesType1Aquarium] = @"Aquarium",
    [PlacesType1Art_gallery] = @"Art gallery",
    [PlacesType1Atm] = @"Atm",
    [PlacesType1Bakery] = @"Bakery",
    [PlacesType1Bank] = @"Bank",
    [PlacesType1Bar] = @"Bar",
    [PlacesType1Beauty_salon] = @"Beauty salon",
    [PlacesType1Bicycle_store] = @"Bicycle store",
    [PlacesType1Book_store] = @"Book store",
    [PlacesType1Bowling_alley] = @"Bowling alley",
    [PlacesType1Bus_station] = @"Bus station",
    [PlacesType1Cafe] = @"Cafe",
    [PlacesType1Campground] = @"Campground",
    [PlacesType1Car_dealer] = @"Car dealer",
    [PlacesType1Car_rental] = @"Car rental",
    [PlacesType1Car_repair] = @"Car repair",
    [PlacesType1Car_wash] = @"Car wash",
    [PlacesType1Casino] = @"Casino",
    [PlacesType1Cemetery] = @"Cemetery",
    [PlacesType1Church] = @"Church",
    [PlacesType1City_hall] = @"City hall",
    [PlacesType1Clothing_store] = @"Clothing store",
    [PlacesType1Convenience_store] = @"Convenience store",
    [PlacesType1Courthouse] = @"Courthouse",
    [PlacesType1Dentist] = @"Dentist",
    [PlacesType1Department_store] = @"Department store",
    [PlacesType1Doctor] = @"Docotr",
    [PlacesType1Electrician] = @"Electrician",
    [PlacesType1Electronics_store] = @"Electronics store",
    [PlacesType1Embassy] = @"Embassy",
    [PlacesType1Establishment] = @"Establishment",
    [PlacesType1Finance] = @"Finance",
    [PlacesType1Fire_station] = @"Fire station",
    [PlacesType1Florist] = @"Florist",
    [PlacesType1Food] = @"Food",
    [PlacesType1Funeral_home] = @"Funeral home",
    [PlacesType1Furniture_store] = @"Furniture store",
    [PlacesType1Gas_station] = @"Gas station",
    [PlacesType1General_contractor] = @"General contractor",
    [PlacesType1Geocode] = @"Geocode",
    [PlacesType1Grocery_or_supermarket] = @"Grocery or supermarket",
    [PlacesType1Gym] = @"Gym",
    [PlacesType1Hair_care] = @"Hair cair",
    [PlacesType1Hardware_store] = @"Hardware store",
    [PlacesType1Health] = @"Health",
    [PlacesType1Hindu_temple] = @"Hindu temple",
    [PlacesType1Home_goods_store] = @"Home goods store",
    [PlacesType1Hospital] = @"Hospital",
    [PlacesType1Insurance_agency] = @"Insurance agency",
    [PlacesType1Jewelry_store] = @"Jewlery store",
    [PlacesType1Laundry] = @"Laundry",
    [PlacesType1Lawyer] = @"Lawyer",
    [PlacesType1Library] = @"Lirbary",
    [PlacesType1Liquor_store] = @"Liquor store",
    [PlacesType1Local_government_office] = @"Local government office",
    [PlacesType1Locksmith] = @"Locksmith",
    [PlacesType1Lodging] = @"Lodging",
    [PlacesType1Meal_delivery] = @"Meal delivery",
    [PlacesType1Meal_takeaway] = @"Meal takeaway",
    [PlacesType1Mosque] = @"Mosque",
    [PlacesType1Movie_rental] = @"Movie rental",
    [PlacesType1Movie_theater] = @"Movie theater",
    [PlacesType1Moving_company] = @"Moving company",
    [PlacesType1Museum] = @"Museum",
    [PlacesType1Night_club] = @"Night club",
    [PlacesType1Painter] = @"Painter",
    [PlacesType1Park] = @"Park",
    [PlacesType1Parking] = @"Parking",
    [PlacesType1Pet_store] = @"Pet store",
    [PlacesType1Pharmacy] = @"Pharmacy",
    [PlacesType1Physiotherapist] = @"Physiotherapist",
    [PlacesType1Place_of_worship] = @"Place of worship",
    [PlacesType1Plumber] = @"PLumber",
    [PlacesType1Police] = @"Police",
    [PlacesType1Post_office] = @"Post office",
    [PlacesType1Real_estate_agency] = @"Real estate agency",
    [PlacesType1Restaurant] = @"Restaurant",
    [PlacesType1Roofing_contractor] = @"Roofing contractor",
    [PlacesType1Rv_park] = @"RvPark",
    [PlacesType1School] = @"School",
    [PlacesType1Shoe_store] = @"Shoe store",
    [PlacesType1Shopping_mall] = @"Shopping mall",
    [PlacesType1Spa] = @"Spa",
    [PlacesType1Stadium] = @"Stadium",
    [PlacesType1Storage] = @"Storage",
    [PlacesType1Store] = @"Store",
    [PlacesType1Subway_station] = @"Subway station",
    [PlacesType1Synagogue] = @"Synagogue",
    [PlacesType1Taxi_stand] = @"Taxi stand",
    [PlacesType1Train_station] = @"Train station",
    [PlacesType1Travel_agency] = @"Travel agency",
    [PlacesType1University] = @"University",
    [PlacesType1Veterinary_care] = @"Veterinary care",
    [PlacesType1Zoo] = @"Zoo",
    [PlacesType1Not_defined] = @"Not_defined"
};

@interface Place : NSObject 

DECLARE_ENUM(PlacesType1)

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *vicinity;
@property (nonatomic,retain) NSString *reference;
@property (nonatomic,retain) NSString *theid;
@property (nonatomic,retain) NSArray *types;
@property (nonatomic,retain) NSURL *iconURL;
@property (nonatomic,retain) Geometry *geometry;

+(Place *)parseJsonDico:(NSDictionary *)jsonDico;

-(NSString *) textualDesc;

@end
