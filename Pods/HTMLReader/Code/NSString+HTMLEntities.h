//  NSString+HTMLEntities.h
//
//  Public domain. https://github.com/nolanw/HTMLReader

#import <Foundation/Foundation.h>

@interface NSString (HTMLEntities)

/**
 * Returns a copy of the string with the necessary characters escaped for HTML.
 *
 * For more information, see http://www.whatwg.org/specs/web-apps/current-work/multipage/the-end.html#escapingString (the algorithm is not invoked in the "attribute mode").
 */
- (NSString *)html_stringByEscapingForHTML;

/**
 * Returns a copy of the string with all recognized HTML entities replaced by their respective code points. If no replacement is necessary, the same instance may be returned.
 */
- (NSString *)html_stringByUnescapingHTML;

@end
