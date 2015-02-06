//
//  ContactCell.h
//  ContactPicker
//
//  Created by 赵进雄 on 14-10-28.
//  Copyright (c) 2014年 zhaojinxiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContact.h"

@interface ContactCell : UITableViewCell

@property (nonatomic, retain) UIImageView *checkboxImageView;
@property (nonatomic, retain) UIImageView *contactImageView;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UILabel *phone;

- (void)showDataWithContact:(THContact *)contact;

@end
