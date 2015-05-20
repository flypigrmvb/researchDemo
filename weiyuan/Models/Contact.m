//
//  Contact.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Contact.h"
#import "NSBaseObject.h"
#import "DBConnection.h"
#import "BSEngine.H"
#import <AddressBook/AddressBook.h>

ABAddressBookRef _addressBook;

@implementation Contact
@synthesize nickname, personId, phone;
@synthesize isfriend, type, uid;

// ABAddressBook-Read
#pragma mark ABAddressBook-Read
+ (NSMutableArray *)readABAddressBook
{
    if (Sys_Version >=6.0f) {
        _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        [self checkAddressBookAccess];
    } else {
//        _addressBook = ABAddressBookCreate();
        CFRetain(_addressBook);
    }
    NSMutableArray *arr = [self accessGrantedForAddressBook];
    [self closeBook];
    return arr;
}

+ (BOOL)canAccessBook {
    if (Sys_Version >=6.0f) {
        switch (ABAddressBookGetAuthorizationStatus())
        {
                // Update our UI if the user has granted access to their Contacts
            case  kABAuthorizationStatusAuthorized:
            case  kABAuthorizationStatusNotDetermined:
                // 用户还没有决定是否授权你的程序进行访问 
                return YES;
                break;
            case  kABAuthorizationStatusDenied:
            case  kABAuthorizationStatusRestricted:
                // iOS设备上的家长控制或其它一些许可配置阻止程序
                return NO;
                break;
            default:
                return YES;
                break;
        }
    }
    return YES;
}

+ (NSData*)getImageByID:(int)personid
{
    if (Sys_Version >=6.0f) {
        _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        [self checkAddressBookAccess];
    } else {
//        _addressBook = ABAddressBookCreate();
        CFRetain(_addressBook);
    }
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, personid);
    __autoreleasing NSData *imageData = nil;
    if (person) {
        imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person,kABPersonImageFormatThumbnail);
        //        CFRelease(person);
    }
    return imageData;
}

+ (NSString*)getNameByID:(int)personid
{
    if (!_addressBook) {
        if (Sys_Version >=6.0f) {
            _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            [self checkAddressBookAccess];
        } else {
            //        _addressBook = ABAddressBookCreate();
            CFRetain(_addressBook);
        }
    }
   
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, personid);
    NSString* personname = (__bridge NSString*)ABRecordCopyCompositeName(person);
    if (personname) {
        return personname;
    }
    return nil;
}

#pragma mark -
#pragma mark Address Book Access
// Check the authorization status of our application for Address Book
+ (void)checkAddressBookAccess
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            CFRetain(_addressBook);
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"抱歉"
                                                            message:@"您已经拒绝我们访问您通讯录！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Address Book data
+ (void)requestAddressBookAccess
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 dispatch_semaphore_signal(sema);
                                                 if (granted) {
                                                     CFRetain(_addressBook);
                                                 }
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

// This method is called when the user has granted access to their address book data.
+ (NSMutableArray*)accessGrantedForAddressBook
{
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    NSMutableArray *arr = [NSMutableArray array];
    if (people) {
        for (id person in (__bridge NSArray*)people) {
            Contact *con = [[Contact alloc] init];
            con.personId = ABRecordGetRecordID((__bridge ABRecordRef)(person));
            NSString* personname = (__bridge NSString*)ABRecordCopyCompositeName( (__bridge ABRecordRef)(person));
            if (personname) {
                if (![personname isEqualToString:@" "]) {
                    con.nickname = personname;
                }
            }
            // phone
            CFTypeRef items = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty);
            if (items) {
                CFStringRef copyPhone = ABMultiValueCopyValueAtIndex(items, 0);
                if (copyPhone) {
                    NSString * personPhone = (__bridge NSString*)copyPhone;
                    con.phone = [personPhone iPhoneStandardFormat];
                    CFRelease(copyPhone);
                } else {
                    con.phone = @"";
                }
                CFRelease(items);
            }
            [arr addObject:con];
            //        CFRelease(copyPhone);
        }
        CFRelease(people);
    }
    return arr;
}

+ (void)closeBook
{
    if (_addressBook) {
        CFRelease(_addressBook);
        _addressBook = nil;
    }
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        self.uid = [dic getStringValueForKey:@"uid" defaultValue:nil];
        self.phone = [dic getStringValueForKey:@"phone" defaultValue:nil];
        self.nickname = [dic getStringValueForKey:@"name" defaultValue:@""];
        self.headsmall = [dic getStringValueForKey:@"headsmall" defaultValue:@""];
        self.verify = [dic getIntValueForKey:@"verify" defaultValue:0];
        self.type = [dic getIntValueForKey:@"type" defaultValue:0];
        self.isfriend = [dic getIntValueForKey:@"isfriend" defaultValue:0];
    }
}

#pragma DB

+ (void)createTableIfNotExists {
	Statement *stmt = [DBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_Contact (uid, phone, name, headsmall, verify, type, sign, isFromLocation, statustype, personid, currentUser, primary key(uid, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

+ (Contact*)contactWithPhone:(NSString *)phone {
    Contact* result = nil;
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM tb_Contact WHERE phone = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:phone forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[Contact alloc] initWithStatement:stmt];
    }
    [stmt reset];
    return result;
}

+ (BOOL)isInlastContacts:(NSString *)contactPhone {
    __block BOOL isIn = NO;
    NSArray * lastArr = [[[BSEngine currentEngine] user] readValueWithKey:@"lastContacts"];
    [lastArr enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:contactPhone]) {
            isIn = YES;
            *stop = YES;
        }
    }];
    return isIn;
}

+ (void)putInlastContacts:(NSArray *)array {
    [[[BSEngine currentEngine] user] saveConfigWhithKey:@"lastContacts" value:array];
}

#pragma DB
- (void)insertDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO tb_Contact VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    int i = 1;
    [stmt bindString:self.uid forIndex:i++];
    [stmt bindString:self.phone forIndex:i++];
    [stmt bindString:self.nickname forIndex:i++];
    [stmt bindString:self.headsmall forIndex:i++];
    [stmt bindInt32:self.verify forIndex:i++];
    [stmt bindInt32:self.type forIndex:i++];
    [stmt bindString:self.sign forIndex:i++];
    [stmt bindInt32:self.isFromLocation forIndex:i++];
    [stmt bindInt32:self.statustype forIndex:i++];
    [stmt bindInt32:self.personId forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        int i = 0;
        self.uid = [stmt getString:i++];
        self.phone = [stmt getString:i++];
        self.nickname = [stmt getString:i++];
        self.headsmall = [stmt getString:i++];
        self.verify = [stmt getInt32:i++];
        self.type = [stmt getInt32:i++];
        self.sign = [stmt getString:i++];
        self.isFromLocation = [stmt getInt32:i++];
        self.statustype = [stmt getInt32:i++];
        self.personId = [stmt getInt32:i++];
	}
	return self;
}

@end