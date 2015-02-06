//
//  ContactPickerViewController.h
//  ContactPicker
//
//  Created by 赵进雄 on 14-10-28.
//  Copyright (c) 2014年 zhaojinxiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "THContact.h"
#import "ContactCell.h"

@interface ContactPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ABPersonViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contactsArray;        // 联系人
@property (nonatomic, strong) NSMutableArray *selectedContacts;    //  选择的联系人
@property (nonatomic, strong) NSMutableArray *allKeysArray;       //   联系人首字母 Key
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) UIBarButtonItem *barButton;
@property (nonatomic, strong)  NSMutableArray *muArray;
@property (nonatomic, strong)  NSMutableDictionary *sortContactsDic;

@end
