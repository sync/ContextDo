#import "UISearchDisplayController+Custom.h"


@implementation UISearchDisplayController(Custom)

- (CustomSearchBar *)customSearchBar
{
	if (![self.searchBar isKindOfClass:[CustomSearchBar class]]) {
		return nil;
	}
	
	return (CustomSearchBar *)self.searchBar;
}

@end
