//
//  MasterViewController.h
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewData.h"
#import <CoreData/CoreData.h>

@interface MainTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>{
@private
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    TableViewData *tableViewData;
    
     }

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) TableViewData *tableViewData;
@property (strong, nonatomic) NSMutableArray *pictureListData;
- (void)showProject:(TableViewData *)tableView animated:(BOOL)animated;

@end
