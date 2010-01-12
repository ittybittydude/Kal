/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalDate.h"
#import "KalPrivate.h"

static NSTimeZone *presentationTimeZone;

@implementation KalDate

+ (void)initialize
{
	presentationTimeZone = nil;
}

+ (KalDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
  return [[[KalDate alloc] initForDay:day month:month year:year] autorelease];
}

+ (KalDate *)dateFromNSDate:(NSDate *)date
{
  NSDateComponents *parts = [date cc_componentsForMonthDayAndYear];
  return [KalDate dateForDay:[parts day] month:[parts month] year:[parts year]];
}

+ (void)setPresentationTimeZone:(NSTimeZone *)timeZone {
	presentationTimeZone = timeZone;
}

+ (KalDate *)today {
	// Calculating 'today' dynamically means the highlighted cell in the calendar updates appropriately when 
	// the day rolls over.
	NSDate *now = nil;
	if (presentationTimeZone != nil)  {
		// Uses the presentation timezone to derive the date/time representing 'now'
		// This supports scenarios where the application's default TimeZone has been changed to GMT, but 
		// you want the calendar to present 'today' in a meaningful way to he user (most likely by setting
		// presentationTimeZone to [NSTimeZone systemTimeZone]).
		now = [NSDate dateWithTimeIntervalSinceNow:[presentationTimeZone secondsFromGMT]];
	} else {
		now = [NSDate date]; // Uses the default timezone to derive the date/time representing 'now'
	}
	
	return [[KalDate dateFromNSDate:now] retain];
}

- (id)initForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
  if ((self = [super init])) {
    a.day = day;
    a.month = month;
    a.year = year;
  }
  return self;
}

- (unsigned int)day { return a.day; }
- (unsigned int)month { return a.month; }
- (unsigned int)year { return a.year; }

- (NSDate *)NSDate
{
  NSDateComponents *c = [[[NSDateComponents alloc] init] autorelease];
  c.day = a.day;
  c.month = a.month;
  c.year = a.year;
  return [[NSCalendar currentCalendar] dateFromComponents:c];
}

- (BOOL)isToday { return [self isEqual:[KalDate today]]; }

- (NSComparisonResult)compare:(KalDate *)otherDate
{
  NSInteger selfComposite = a.year*10000 + a.month*100 + a.day;
  NSInteger otherComposite = [otherDate year]*10000 + [otherDate month]*100 + [otherDate day];
  
  if (selfComposite < otherComposite)
    return NSOrderedAscending;
  else if (selfComposite == otherComposite)
    return NSOrderedSame;
  else
    return NSOrderedDescending;
}

#pragma mark -
#pragma mark NSObject interface

- (BOOL)isEqual:(id)anObject
{
  if (![anObject isKindOfClass:[KalDate class]])
    return NO;
  
  KalDate *d = (KalDate*)anObject;
  return a.day == [d day] && a.month == [d month] && a.year == [d year];
}

- (NSUInteger)hash
{
  return a.day;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%u/%u/%u", a.month, a.day, a.year];
}

@end
