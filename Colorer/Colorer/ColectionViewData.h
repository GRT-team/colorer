//
//  ColectionViewData.h
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TableViewData;

@interface ColectionViewData : NSManagedObject

@property (nonatomic, retain) NSNumber * colId;
@property (nonatomic, retain) NSData * colViewImage;
@property (nonatomic, retain) NSData * detailImage;
@property (nonatomic, retain) TableViewData *collectionImage;

@end
