//
//  TableViewData.h
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ColectionViewData;

@interface TableViewData : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * tableImage;
@property (nonatomic, retain) NSSet *imageincollection;
@end

@interface TableViewData (CoreDataGeneratedAccessors)

- (void)addImageincollectionObject:(ColectionViewData *)value;
- (void)removeImageincollectionObject:(ColectionViewData *)value;
- (void)addImageincollection:(NSSet *)values;
- (void)removeImageincollection:(NSSet *)values;

@end
