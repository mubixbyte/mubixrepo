#import "AFPFontListController.h"
#import <UIKit/UIKit.h>

@implementation AFPFontListController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *displayName = cell.textLabel.text;
    NSString *fontName = displayName;

    if ([displayName hasPrefix:@"Automatic ("] && [displayName hasSuffix:@")"]) {
        fontName = [displayName substringWithRange:NSMakeRange(11, displayName.length - 12)];
    }

    UIFont *previewFont = [UIFont fontWithName:fontName size:17.0];
    if (!previewFont) {
        NSString *familyName = displayName;
        NSArray<NSString *> *familyFonts = [UIFont fontNamesForFamilyName:familyName];
        if (familyFonts.count > 0) previewFont = [UIFont fontWithName:familyFonts.firstObject size:17.0];
    }

    cell.textLabel.font = previewFont ?: [UIFont systemFontOfSize:17.0];
    cell.textLabel.text = displayName.length > 0 ? displayName : @"Без названия";
    return cell;
}

@end
