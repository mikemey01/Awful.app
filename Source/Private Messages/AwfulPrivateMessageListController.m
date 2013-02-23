//
//  AwfulPrivateMessageListController.m
//  Awful
//
//  Created by me on 7/20/12.
//  Copyright (c) 2012 Regular Berry Software LLC. All rights reserved.
//

#import "AwfulPrivateMessageListController.h"
#import "AwfulFetchedTableViewControllerSubclass.h"
#import "AwfulDataStack.h"
#import "AwfulDisclosureIndicatorView.h"
#import "AwfulModels.h"
#import "AwfulNewPMNotifierAgent.h"
#import "AwfulPrivateMessageViewController.h"
#import "AwfulSettings.h"
#import "AwfulSplitViewController.h"
#import "AwfulTheme.h"
#import "AwfulThreadCell.h"
#import "AwfulThreadTags.h"
#import "UIViewController+NavigationEnclosure.h"

@implementation AwfulPrivateMessageListController

#pragma mark - AwfulFetchedTableViewController

- (id)init
{
    if (!(self = [super init])) return nil;
    self.title = @"Private Messages";
    self.tabBarItem.image = [UIImage imageNamed:@"pm-icon.png"];
    UIBarButtonItem *compose;
    compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                            target:self
                                                            action:@selector(didTapCompose:)];
    self.navigationItem.rightBarButtonItem = compose;
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"PMs"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:nil action:NULL];
    self.navigationItem.backBarButtonItem = back;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNewPMCount:)
                                                 name:AwfulNewPrivateMessagesNotification
                                               object:nil];
    return self;
}

- (void)didTapCompose:(id)sender
{
    // TODO
}

- (void)didGetNewPMCount:(NSNotification*)notification
{
    NSNumber *count = notification.userInfo[kAwfulNewPrivateMessageCountKey];
    self.tabBarItem.badgeValue = [count integerValue] ? [count stringValue] : nil;
    self.refreshing = NO;
}

- (NSFetchedResultsController *)createFetchedResultsController
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:
                               [AwfulPrivateMessage entityName]];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"sentDate"
                                                               ascending:NO] ];
    NSManagedObjectContext *context = [AwfulDataStack sharedDataStack].context;
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:context
                                                 sectionNameKeyPath:nil cacheName:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 75;
}

-(BOOL)refreshOnAppear
{
    if ([self.fetchedResultsController.fetchedObjects count] == 0) return YES;
    AwfulNewPMNotifierAgent *agent = [AwfulNewPMNotifierAgent defaultAgent];
    if (!agent.lastCheckDate) return YES;
    const NSTimeInterval checkingThreshhold = 10 * 60;
    return (-[agent.lastCheckDate timeIntervalSinceNow] > checkingThreshhold);
}

- (void)refresh
{
    [super refresh];
    [[AwfulNewPMNotifierAgent defaultAgent] checkForNewMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const Identifier = @"AwfulPrivateMessageCell";
    AwfulThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[AwfulThreadCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:Identifier];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            cell.accessoryView = [AwfulDisclosureIndicatorView new];
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)genericCell atIndexPath:(NSIndexPath *)indexPath
{
    AwfulThreadCell *cell = (id)genericCell;
    AwfulPrivateMessage *pm = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([AwfulSettings settings].showThreadTags) {
        cell.imageView.hidden = NO;
        cell.imageView.image = [[AwfulThreadTags sharedThreadTags]
                                threadTagNamed:pm.firstIconName];
        if (!cell.imageView.image && pm.firstIconName) {
            // TODO handle missing thread tag updates
//            [self updateThreadTag:pm.firstIconName forCellAtIndexPath:indexPath];
        }
        cell.secondaryTagImageView.hidden = YES;
        cell.sticky = NO;
        cell.rating = 0;
    } else {
        cell.imageView.image = nil;
        cell.imageView.hidden = YES;
        cell.secondaryTagImageView.image = nil;
        cell.secondaryTagImageView.hidden = YES;
        cell.sticky = NO;
        cell.closed = NO;
        cell.rating = 0;
    }
    
    AwfulTheme *theme = [AwfulTheme currentTheme];
    cell.textLabel.text = pm.subject;
    cell.textLabel.textColor = theme.threadCellTextColor;
    
    cell.detailTextLabel.text = pm.from.username;
    cell.detailTextLabel.textColor = theme.threadCellPagesTextColor;
    
    cell.backgroundColor = theme.threadCellBackgroundColor;
    cell.selectionStyle = theme.cellSelectionStyle;
    
    if (!pm.seenValue) {
        cell.showsUnread = YES;
        cell.unreadCountBadgeView.badgeText = @"New";
    } else {
        cell.showsUnread = NO;
    }
    
    // TODO add accessory icon for forward/replied
    
    AwfulDisclosureIndicatorView *disclosure = (AwfulDisclosureIndicatorView *)cell.accessoryView;
    disclosure.color = theme.disclosureIndicatorColor;
    disclosure.highlightedColor = theme.disclosureIndicatorHighlightedColor;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AwfulPrivateMessage *pm = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AwfulPrivateMessageViewController *vc;
    vc = [[AwfulPrivateMessageViewController alloc] initWithPrivateMessage:pm];
    AwfulSplitViewController *split = (AwfulSplitViewController *)self.splitViewController;
    if (!split) {
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UINavigationController *nav = (id)split.viewControllers[1];
        nav.viewControllers = @[ vc ];
        [split.masterPopoverController dismissPopoverAnimated:YES];
    }
}

@end