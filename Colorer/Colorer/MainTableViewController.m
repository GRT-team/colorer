//
//  MasterViewController.m
//  Painting
//
//  Created by Illya Kyznetsov on 17.12.12.
//  Copyright (c) 2012 Illya Kyznetsov. All rights reserved.
//

#import "MainTableViewController.h"
#import "CollectionViewController.h"
#import "TableViewCell.h"

@interface MainTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MainTableViewController
@synthesize managedObjectContext, fetchedResultsController,tableViewData,pictureListData;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.rowHeight = 100.f;
   
    //  Force table refresh
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    numberOfRows = [sectionInfo numberOfObjects];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
        }




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CollectionViewController *pld = (CollectionViewController *)[segue destinationViewController];
    
    //  Pass the managed object context to the destination view controller
    pld.managedObjectContext = managedObjectContext;
    
    //  If we are editing a picture we need to pass some stuff, so check the segue title first
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        //  Get the row we selected to view
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        //  Pass the picture object from the table that we want to view
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TableViewData *project = (TableViewData *)[fetchedResultsController objectAtIndexPath:indexPath];
        pld.tableViewData = project;
     //   pld.tableViewData = self.tableViewData;
    }
   
}
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TableViewData" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}
/*
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{/*
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
  
    TableViewData *recipe = (TableViewData *)[fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = recipe.name;
}
*/

- (void)configureCell:(TableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //TableViewCell *cell = (TableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    TableViewData *recipe = (TableViewData *)[fetchedResultsController objectAtIndexPath:indexPath];
    
        cell.name.text = recipe.name;
;
    cell.photo.image = [UIImage imageWithData:recipe.tableImage];

    }


@end
