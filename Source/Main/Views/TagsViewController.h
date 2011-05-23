#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "TITokenFieldView.h"

@interface TagsViewController : BaseViewController <TITokenFieldDelegate> {

}

@property (nonatomic, retain) IBOutlet TITokenField *tagsLabel;

@end
