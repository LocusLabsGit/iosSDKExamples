//
//  MainViewController.m
//  UIExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"

@interface MainViewController ()

@end
// ---------------------------------------------------------------------------------------------------------------------
// MainViewController
//
//  - viewDidLoad
// ---------------------------------------------------------------------------------------------------------------------

@implementation MainViewController

NSArray *examples;

- (void)awakeFromNib  {
    [super awakeFromNib];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    examples = [NSArray arrayWithObjects:@"Change font", @"Change background", @"Change color bottom bar", @"Change text back button", nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//the user clicks on the theme that he wants to see
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    ViewController *destViewController = segue.destinationViewController;
    destViewController.theme = [examples objectAtIndex:indexPath.row];
}

//get the number of cells in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [examples count];
}

//initalize each cell in the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierCell = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierCell];
    }
    
    cell.textLabel.text = [examples objectAtIndex:indexPath.row];
    
    return cell;
}

//select the cell that the user clicks and perform the segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"setTheme" sender:self];
}

@end
