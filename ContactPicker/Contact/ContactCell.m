//
//  ContactCell.m
//  ContactPicker
//
//  Created by 赵进雄 on 14-10-28.
//  Copyright (c) 2014年 zhaojinxiong. All rights reserved.
//

#import "ContactCell.h"
#import "NSString+Telephone.h"

@implementation ContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _checkboxImageView = [[UIImageView alloc]initWithFrame:CGRectMake(11, 21, 25, 25)];
        _checkboxImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_checkboxImageView];
        
        _contactImageView = [[UIImageView alloc]initWithFrame:CGRectMake(46, 14, 40, 40)];
        _contactImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_contactImageView];
        
        _name = [[UILabel alloc]initWithFrame:CGRectMake(94, 12, 200, 21)];
        _name.font = [UIFont systemFontOfSize:14.f];
        _name.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_name];
        
        _phone = [[UILabel alloc]initWithFrame:CGRectMake(94, 35, 132, 21)];
        _phone.font = [UIFont systemFontOfSize:14.f];
        _phone.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_phone];
        
    }
    return self;
}

- (void)showDataWithContact:(THContact *)contact
{
    // Assign values to to US elements
    _name.text = [contact fullName];
    _phone.text = [contact.phone telephoneWithReformat];
    if(contact.image) {
        _contactImageView.image = contact.image;
    }
    _contactImageView.layer.masksToBounds = YES;
    _contactImageView.layer.cornerRadius = 20;
    
    // Set the checked state for the contact selection checkbox
    if (contact.selected) {
        _checkboxImageView.image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    }
    else
    {
        _checkboxImageView.image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_name setText:nil];
    [_phone setText:nil];
}


@end
