//
//  TableViewController.m
//  ToDoList
//
//  Created by John on 10/11/13.
//  Copyright (c) 2013 John. All rights reserved.
//

#import "TableViewController.h"
#import "CustomCell.h"

@interface TableViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TableViewController

//override - lazy instantiation of mutable array
-(NSMutableArray*) toDoListItems
{
    if (_toDoListItems == nil) {
        _toDoListItems = [[NSMutableArray alloc] init];
    }
    return _toDoListItems;
}

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
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    // set done button in nav bar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishEdit:)];
    // set done button in nav bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editList:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = editButton;
    
    // set up tableView delegate and data source
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    // set up & register custom Nib
    UINib *customNib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"CustomCell"];
    
    // add initial data to be displayed
    [self.toDoListItems addObject:@"Groceries"];
    [self.toDoListItems addObject:@"Pick up at Airport"];
    [self.toDoListItems addObject:@"Buy Movie Tickets"];
    
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
    
    // set delegate here
    //cell.textField.delegate = self;

    // Configure the cell text
    cell.cellField.text = [self.toDoListItems objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Utility methods

// load blank cell
- (IBAction)addItem:(id)sender {
    //[self.toDoListItems addObject:@""];
    [self.toDoListItems insertObject:@"" atIndex:0];
    [self.tableView setEditing:YES animated:YES];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishEdit:)];
    self.navigationItem.leftBarButtonItem = doneButton;

    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];
}

- (IBAction)editList:(id)sender {
    [self.tableView setEditing:YES animated:YES];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishEdit:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
}

- (IBAction)finishEdit:(id)sender
{
    // set done button in nav bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editList:)];
    self.navigationItem.leftBarButtonItem = editButton;
    
    // set add button in nav bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // ****** persist all items in the to do list
    
    // collect all cells
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            [cells addObject:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    
    // store cell values
    for (NSInteger k = 0; k < [cells count]; ++k)
    {
        CustomCell *cell = [cells objectAtIndex:k];
        NSLog(cell.cellField.text);
        [self.toDoListItems replaceObjectAtIndex:k withObject:cell.cellField.text];
    }
    
    
    [self.tableView setEditing:NO animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"finished editing");
    [self.toDoListItems replaceObjectAtIndex:0 withObject:textField.text];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"Should return");
    return NO;
}

#pragma mark - button utility methods
- (void)addAddButtonAsRightNavButton:(id)sender
{
    // set add button in nav bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

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
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationLeft];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

- (void) setEditing:(BOOL)editing
           animated:(BOOL)animated{
    
    [super setEditing:editing
             animated:animated];
    
    [self.tableView setEditing:editing
                        animated:animated];
    
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
