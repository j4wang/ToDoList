//
//  TableViewController.h
//  ToDoList
//
//  Created by John on 10/11/13.
//  Copyright (c) 2013 John. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController

// add supported protocols
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

//this will hold the data
@property (strong, nonatomic) NSMutableArray *toDoListItems;

- (IBAction)addItem:(id)sender;
- (IBAction)editList:(id)sender;
- (IBAction)

@end
