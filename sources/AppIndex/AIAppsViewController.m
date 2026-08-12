#import "AIAppsViewController.h"
#import <objc/message.h>

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray *)allApplications;
@end

@interface AIAppsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UISegmentedControl *segments;
@property(nonatomic, copy) NSArray<NSDictionary *> *applications;
@property(nonatomic, copy) NSArray<NSDictionary *> *visibleApplications;
@property(nonatomic, copy) NSString *query;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation AIAppsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Все приложения";
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.applications = @[];
    self.visibleApplications = @[];

    self.segments = [[UISegmentedControl alloc] initWithItems:@[@"Все", @"Польз.", @"Система", @"Скрытые"]];
    self.segments.selectedSegmentIndex = 0;
    [self.segments addTarget:self action:@selector(filterChanged) forControlEvents:UIControlEventValueChanged];
    self.segments.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.segments];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 66;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.spinner];

    [NSLayoutConstraint activateConstraints:@[
        [self.segments.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [self.segments.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.segments.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.tableView.topAnchor constraintEqualToAnchor:self.segments.bottomAnchor constant:8],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.spinner.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];

    UISearchController *search = [[UISearchController alloc] initWithSearchResultsController:nil];
    search.searchResultsUpdater = self;
    search.obscuresBackgroundDuringPresentation = NO;
    search.searchBar.placeholder = @"Название или bundle ID";
    self.navigationItem.searchController = search;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadApplications)];
    [self loadApplications];
}

- (void)loadApplications {
    [self.spinner startAnimating];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        id workspace = [NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace];
        NSArray *proxies = [workspace respondsToSelector:@selector(allApplications)] ? [workspace allApplications] : @[];
        NSMutableArray *items = [NSMutableArray array];
        for (id proxy in proxies) @autoreleasepool {
            NSString *identifier = [self safeValue:@"bundleIdentifier" from:proxy] ?: @"";
            if (!identifier.length || [identifier isEqualToString:@"com.mubixbyte.appindex"]) continue;
            NSString *name = [self safeValue:@"localizedName" from:proxy] ?: [self safeValue:@"itemName" from:proxy] ?: identifier;
            NSString *type = [self safeValue:@"applicationType" from:proxy] ?: @"Unknown";
            NSArray *tags = [self safeValue:@"appTags" from:proxy];
            BOOL system = [type caseInsensitiveCompare:@"System"] == NSOrderedSame;
            BOOL hidden = NO;
            for (id tag in [tags isKindOfClass:NSArray.class] ? tags : @[]) {
                NSString *text = [[tag description] lowercaseString];
                if ([text containsString:@"hidden"] || [text containsString:@"invisible"] || [text containsString:@"system-service"]) { hidden = YES; break; }
            }
            [items addObject:@{@"name":name, @"identifier":identifier, @"system":@(system), @"hidden":@(hidden), @"type":type}];
        }
        [items sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
            return [a[@"name"] localizedCaseInsensitiveCompare:b[@"name"]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.applications = items;
            [self applyFilter];
            [self.spinner stopAnimating];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        });
    });
}

- (id)safeValue:(NSString *)key from:(id)object {
    @try { return [object valueForKey:key]; } @catch (__unused NSException *exception) { return nil; }
}

- (void)filterChanged { [self applyFilter]; }
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.query = searchController.searchBar.text ?: @"";
    [self applyFilter];
}

- (void)applyFilter {
    NSString *query = self.query.lowercaseString ?: @"";
    NSInteger mode = self.segments.selectedSegmentIndex;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *item, NSDictionary *bindings) {
        BOOL category = mode == 0 || (mode == 1 && ![item[@"system"] boolValue]) || (mode == 2 && [item[@"system"] boolValue]) || (mode == 3 && [item[@"hidden"] boolValue]);
        BOOL search = !query.length || [[item[@"name"] lowercaseString] containsString:query] || [[item[@"identifier"] lowercaseString] containsString:query];
        return category && search;
    }];
    self.visibleApplications = [self.applications filteredArrayUsingPredicate:predicate];
    self.title = [NSString stringWithFormat:@"Приложения · %lu", (unsigned long)self.visibleApplications.count];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.visibleApplications.count; }
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Некоторые внутренние системные компоненты не имеют интерфейса и могут не открыться.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuse = @"App";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
    NSDictionary *item = self.visibleApplications[indexPath.row];
    cell.textLabel.text = item[@"name"];
    NSString *suffix = [item[@"hidden"] boolValue] ? @" · скрытое" : ([item[@"system"] boolValue] ? @" · системное" : @"");
    cell.detailTextLabel.text = [item[@"identifier"] stringByAppendingString:suffix];
    cell.detailTextLabel.textColor = UIColor.secondaryLabelColor;
    cell.imageView.image = [self iconForIdentifier:item[@"identifier"]];
    cell.imageView.layer.cornerRadius = 11;
    cell.imageView.clipsToBounds = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UIImage *)iconForIdentifier:(NSString *)identifier {
    SEL selector = NSSelectorFromString(@"_applicationIconImageForBundleIdentifier:format:scale:");
    if ([UIImage respondsToSelector:selector]) {
        UIImage *(*implementation)(id, SEL, NSString *, int, CGFloat) = (void *)objc_msgSend;
        UIImage *image = implementation(UIImage.class, selector, identifier, 2, UIScreen.mainScreen.scale);
        if (image) return image;
    }
    return [UIImage systemImageNamed:@"app.fill"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.visibleApplications[indexPath.row];
    [self openIdentifier:item[@"identifier"] name:item[@"name"]];
}

- (void)openIdentifier:(NSString *)identifier name:(NSString *)name {
    id workspace = [NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace];
    SEL selector = NSSelectorFromString(@"openApplicationWithBundleID:");
    BOOL opened = NO;
    if ([workspace respondsToSelector:selector]) {
        BOOL (*implementation)(id, SEL, NSString *) = (void *)objc_msgSend;
        opened = implementation(workspace, selector, identifier);
    }
    if (!opened && [UIApplication.sharedApplication respondsToSelector:NSSelectorFromString(@"launchApplicationWithIdentifier:suspended:")]) {
        BOOL (*fallback)(id, SEL, NSString *, BOOL) = (void *)objc_msgSend;
        opened = fallback(UIApplication.sharedApplication, NSSelectorFromString(@"launchApplicationWithIdentifier:suspended:"), identifier, NO);
    }
    if (!opened) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Не удалось открыть" message:[NSString stringWithFormat:@"%@ (%@) может быть внутренним сервисом без пользовательского интерфейса.", name, identifier] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Скопировать ID" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) { UIPasteboard.generalPasteboard.string = identifier; }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
