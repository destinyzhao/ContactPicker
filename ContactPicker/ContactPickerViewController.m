//
//  ContactPickerViewController.m
//  ContactPicker
//
//  Created by 赵进雄 on 14-10-28.
//  Copyright (c) 2014年 zhaojinxiong. All rights reserved.
//

#import "ContactPickerViewController.h"
#import <Foundation/Foundation.h>
#import "NSString+telephone.h"
#import "pinyin.h"

@interface ContactPickerViewController ()

@end

@implementation ContactPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    _barButton.enabled = FALSE;
    
    self.navigationItem.rightBarButtonItem = _barButton;
    
     _muArray=[NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
        }
    });
}

- (void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
       _contactsArray = [NSMutableArray new];
       
        for (NSUInteger i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
            // Get first and last names and fullName
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(contactPerson);

            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            if (fullName != nil){
                contact.fullName = fullName;
            }
            else if(firstName != nil && lastName != nil) {
                contact.fullName = [NSString stringWithFormat:@"%@%@",lastName,firstName];
            } else if (firstName != nil) {
                contact.fullName = firstName;
            } else if (lastName != nil) {
                contact.fullName = lastName;
            } else {
                contact.fullName = @"";
            }
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSString *telephone = [self getMobilePhoneProperty:phonesRef];
            contact.phone = telephone;
            
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            UIImage *userImg = [UIImage imageWithData:imgData];
            contact.image = userImg;
            
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
            }
            
           
            NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
            NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"; //中国移动：China Mobile
            NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$"; //中国联通：China Unicom
            NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$"; //中国电信：China Telecom
            
            NSString *phone = [contact.phone telephoneWithReformat];
            
            NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
            NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
            NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
            NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
            BOOL res1 = [regextestmobile evaluateWithObject:phone];
            BOOL res2 = [regextestcm evaluateWithObject:phone];
            BOOL res3 = [regextestcu evaluateWithObject:phone];
            BOOL res4 = [regextestct evaluateWithObject:phone];
            
            if (res1 || res2 || res3 || res4 )
            {
                [_contactsArray addObject:contact];
            }
        }
        
        NSLog(@"%@",[[_contactsArray objectAtIndex:0] fullName]);
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        self.selectedContacts = [NSMutableArray array];
        
        // 排序:建立一个字典,字典保存key是A-Z 值是数组
        _sortContactsDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        for (THContact *addresBook in _contactsArray) {
            
            NSString *fullName = addresBook.fullName;
            //获得中文拼音首字母，如果是英文或数字则#
            NSString *strFirLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([fullName characterAtIndex:0])] uppercaseString];
            
            if ([strFirLetter isEqualToString:@"#"]) {
                //转换为小写
                strFirLetter= [[fullName substringToIndex:1]uppercaseStringWithLocale:[NSLocale currentLocale]];
                
                NSString *numberRegex = @"^[0-9]*$";
                NSPredicate *accountTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
                if([accountTest evaluateWithObject:strFirLetter])
                {
                     strFirLetter = @"#";
                }
            }
            
            if ([[_sortContactsDic allKeys]containsObject:strFirLetter]) {
                //判断字典中是否有这个key,如果有取出值进行追加操作
                [[_sortContactsDic objectForKey:strFirLetter] addObject:addresBook];
            }else{
                NSMutableArray *tempArray = [NSMutableArray array];
                [tempArray addObject:addresBook];
                [_sortContactsDic setObject:tempArray forKey:strFirLetter];
            }
            
        }

        NSLog(@"sortDic:%@",_sortContactsDic);
        
        // key 排序
        _allKeysArray = [NSMutableArray arrayWithArray:[[_sortContactsDic allKeys] sortedArrayUsingSelector:@selector(compare:)]];
        
        [self.tableView reloadData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        //CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        switch (i) {
            case 0: {// Phone number
                return  (__bridge NSString *)currentPhoneValue;
                break;
            }
            case 1: {// Email
                return  (__bridge NSString*)currentPhoneValue;
                break;
            }
        }

    }
    
    return nil;
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return _allKeysArray;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    else
    {
        if (title == UITableViewIndexSearch)
        {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        }
        else
        {
            return index;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [[_sortContactsDic allKeys] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [_allKeysArray count]?[_allKeysArray objectAtIndex:section]:nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 0;
    NSArray *arry=[_sortContactsDic allKeys];
    return [arry count] ? tableView.sectionHeaderHeight : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_allKeysArray objectAtIndex:section];
    NSArray *contactArry = [_sortContactsDic objectForKey:key];
    return [contactArry count];
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the desired contact from the filteredContacts array
    NSString *key = [_allKeysArray objectAtIndex:indexPath.section];
    NSArray *contactArry = [_sortContactsDic objectForKey:key];
    THContact *contact = [contactArry objectAtIndex:indexPath.row];
    
    // Initialize the table view cell
    NSString *cellIdentifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell showDataWithContact:contact];
    
    // Assign a UIButton to the accessoryView cell property
    //cell.accessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    // Set a target and selector for the accessoryView UIControlEventTouchUpInside
    [(UIButton *)cell.accessoryView addTarget:self action:@selector(viewContactDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryView.tag = contact.recordId; //so we know which ABRecord in the IBAction method
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = nil;
    
    NSString *key = [_allKeysArray objectAtIndex:indexPath.section];
    NSArray *contactArry = [_sortContactsDic objectForKey:key];
    THContact *user = [contactArry objectAtIndex:indexPath.row];
 
    [cell showDataWithContact:user];
    
    NSString *str;
    NSString *phone;
    
    if ([self.selectedContacts containsObject:user]){
        [self.selectedContacts removeObject:user];
        user.selected = NO;
        
        phone = [user.phone telephoneWithReformat];
        [_muArray removeObject: phone];
        str= [_muArray componentsJoinedByString:@";"];
        
    } else {
        
        if(self.selectedContacts.count < 5)
        {
            [self.selectedContacts addObject:user];
            user.selected = YES;
            
            phone = [user.phone telephoneWithReformat];
            [_muArray addObject:phone];
            str= [_muArray componentsJoinedByString:@";"];

        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"最多添加5个联系人" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    }
    
    
    // Refresh the tableview
    [self.tableView reloadData];
}

#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);
    
    
    [self.navigationController pushViewController:view animated:YES];
}

// TODO: send contact object
- (void)done:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Done!"
                                                        message:@"Now do whatevet you want!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
