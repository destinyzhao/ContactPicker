//
//  NSString+telephone.m
//  ContactPicker
//
//  Created by 赵进雄 on 14-11-20.
//  Copyright (c) 2014年 zhaojinxiong. All rights reserved.
//

#import "NSString+telephone.h"

@implementation NSString (telephone)

- (BOOL)containsString:(NSString *)aString
{
    NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
    return range.location != NSNotFound;
}

- (NSString *)telephoneWithReformat
{
    NSString *telephone = self;
    if ([telephone containsString:@"-"])
    {
        telephone = [telephone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if ([self containsString:@" "])
    {
        telephone = [telephone stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if ([telephone containsString:@"("])
    {
        telephone = [telephone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    }
    
    if ([telephone containsString:@")"])
    {
        telephone = [telephone stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    
    if ([self containsString:@" "])
    {
        telephone = [telephone stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    return telephone;
}

@end
