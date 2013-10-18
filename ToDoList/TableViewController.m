//
//  TableViewController.m
//  ToDoList
//
//  Created by John on 10/11/13.
//  Copyright (c) 2013 John. All rights reserved.
//

#import "TableViewController.h"
#import "CustomCell.h"
#import <objc/runtime.h>

@interface TableViewController ()

@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL addNewItem;

@end

@implementation TableViewController


//override - lazy instantiation of mutable array
/*
-(NSMutableArray*) toDoListItems
{
    
    if (self.toDoListItems == nil) {
        self.toDoListItems = [[NSMutableArray alloc] init];
    }
    return self.toDoListItems;
}
*/
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"To Do List";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set add button in nav bar
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    // set edit button in nav bar
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editList:)];
    
    self.navigationItem.rightBarButtonItem = self.addButton;
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    // set up tableView delegate and data source
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    // set up & register custom Nib
    UINib *customNib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"CustomCell"];
    
    // add initial data to be displayed: load array from NSUserDefaults
    NSUserDefaults *mySavedList = [NSUserDefaults standardUserDefaults];
    NSMutableArray *retArray = [[NSMutableArray alloc] initWithArray:((NSMutableArray *) [mySavedList objectForKey:@"myToDoList"])];
    if(retArray != nil)
    {
        // object is in NSUserDefaults, get and set as value of to do list
        self.toDoListItems = retArray;
    }
    // object doesn't exist, initialize array and save for key
    else
    {
        self.toDoListItems = [[NSMutableArray alloc] init];
        [mySavedList setObject:self.toDoListItems forKey:@"myToDoList"];
    }

    //[self.toDoListItems addObject:@"Groceries"];
    //[self.toDoListItems addObject:@"Pick up at Airport"];
    //[self.toDoListItems addObject:@"Buy Movie Tickets"];
    
    NSString *rowCount = [NSString stringWithFormat:@"Row count after load: %d", [self.toDoListItems count]];
    NSLog(rowCount);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *rowCount = [NSString stringWithFormat:@"Row count: %d", [self.toDoListItems count]];
    NSLog(rowCount);
    return [self.toDoListItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // set CustomCell delegate here
    cell.cellField.delegate = self;

    // Configure the cell text
    cell.cellField.text = [self.toDoListItems objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Utility methods (Selectors)

// load blank cell
- (IBAction)addItem:(id)sender {
    NSLog(@"Add Item");
    //[self.toDoListItems addObject:@""];
    [self.toDoListItems insertObject:@"" atIndex:0];
    
    // disable buttons
    self.addButton.enabled = NO;
    self.editButton.enabled = NO;
    
    // set flag
    self.addNewItem = YES;
    
    [self.tableView setEditing:YES animated:YES];

    [self.tableView reloadData];
}

- (IBAction)editList:(id)sender {
    self.editButton.enabled = false;
    [self.tableView setEditing:YES animated:YES];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    // update and persist
    [self updateListFromTextField:textField];
    // exit editing mode
    [self.tableView  setEditing:NO animated:YES];
    
    // restore buttons
    self.addButton.enabled = YES;
    self.editButton.enabled = YES;
    
    NSLog(@"Should return - end editing");
    return NO;
}

#pragma mark - button utility methods
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /* First remove this object from the source */
        [self.toDoListItems removeObjectAtIndex:indexPath.row];
        
        /* Then remove the associated cell from the Table View */
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self.toDoListItems insertObject:@"" atIndex:indexPath.row];
        
        [self.tableView reloadData];

    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id buffer = [self.toDoListItems objectAtIndex:fromIndexPath.row];
    [self.toDoListItems removeObjectAtIndex:fromIndexPath.row];
    [self.toDoListItems insertObject:buffer atIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
    
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    // reset the addNewItem flag
    if(self.addNewItem)
    {
        self.addNewItem = NO;
    }
    
    // manage the buttons
    if(editing)
    {
        self.addButton.enabled = NO;
        self.editButton.enabled = NO;
    }
    else
    {
        self.addButton.enabled = YES;
        self.editButton.enabled = YES;
    }
    
    [self.tableView reloadData];
}

- (void)updateListFromTextField:(UITextField *)textField
{
    NSString *toDoListText = textField.text;
    NSIndexPath *indexPath = objc_getAssociatedObject(self, (__bridge const void *)(textField));
    
    [self.toDoListItems setObject:toDoListText atIndexedSubscript:indexPath.row];
    
    //persist array into NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:self.toDoListItems forKey:@"myToDoList"];
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
