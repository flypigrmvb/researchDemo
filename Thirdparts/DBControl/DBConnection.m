#import "DBConnection.h"
#import "Statement.h"
#import "Globals.h"

#define DB_V_S @"DB_Version_Store"

static sqlite3*             theDatabase = nil;


//#define TEST_DELETE_TWEET

#ifdef TEST_DELETE_TWEET
const char *delete_tweets = 
"BEGIN;"
//"DELETE FROM statuses;"
//"DELETE FROM direct_messages;"
//"DELETE FROM images;"
//"DELETE FROM statuses WHERE type = 0 and id > (SELECT id FROM statuses WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 1);"
//"DELETE FROM statuses WHERE type = 1 and id > (SELECT id FROM statuses WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 1);"
//"DELETE FROM direct_messages WHERE id > (SELECT id FROM direct_messages ORDER BY id DESC LIMIT 1 OFFSET 10);"
"COMMIT";
#endif

@implementation DBConnection

+ (sqlite3*)openDatabase:(NSString*)dbFilename
{
    sqlite3* instance = NULL;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &instance) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(instance);
        DLog(@"Failed to open database. (%s)", sqlite3_errmsg(instance));
        return nil;
    }        
    return instance;
}

+(void)dbVersionControl
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * version_old = [defaults objectForKey:DB_V_S];
    NSString * version_new = [NSString stringWithFormat:@"%@", DB_Version];
    DLog(@"DB[Version] before: [%@] after: [%@]",version_old,version_new);
    
    if ( version_old == nil || ![version_new isEqualToString:version_old]) {
        DLog(@"del db file!!!");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
        if ([fileManager fileExistsAtPath:writableDBPath]) {
            [fileManager removeItemAtPath:writableDBPath error:&error];
            if (error) {
                DLog(@"Can not delete DB file with error : %@", [error localizedFailureReason]);
            }
        }

        [defaults setValue:version_new forKey:DB_V_S];
        [defaults synchronize];
    }
}

+ (sqlite3*)getSharedDatabase
{
    [DBConnection dbVersionControl];
    if (theDatabase == nil) {
        theDatabase = [self openDatabase:MAIN_DATABASE_NAME];
        if (theDatabase == nil) {
            [DBConnection createEditableCopyOfDatabaseIfNeeded:true];
        }
        
#ifdef TEST_DELETE_TWEET
        char *errmsg;
        if (sqlite3_exec(theDatabase, delete_tweets, NULL, NULL, &errmsg) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to cleanup chache (%s)", errmsg);
        }
#endif
    }
    
    return theDatabase;
}

//
// delete caches
//
const char *delete_message_cache_sql = 
"BEGIN;"
"DELETE FROM timeline;"
"DELETE FROM favorites;"
"DELETE FROM drafts;"
"DELETE FROM userComments;"
"DELETE FROM comments;"
"DELETE FROM mentions;"
"DELETE FROM statuses;"
"DELETE FROM directMessages;"
"DELETE FROM users;"
"COMMIT;"
"VACUUM;";

+ (void)deleteMessageCache
{
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, delete_message_cache_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        DLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

//
// cleanup and optimize
//
const char *cleanup_sql =
"BEGIN;"
"DELETE FROM userComments WHERE commentId <= (SELECT commentId FROM userComments ORDER BY commentId DESC LIMIT 1 OFFSET 1000);"
"DELETE FROM comments WHERE commentId NOT IN (SELECT commentId FROM userComments);"
"DELETE FROM mentions WHERE statusId <= (SELECT statusId FROM mentions ORDER BY statusId DESC LIMIT 1 OFFSET 4000);"
"DELETE FROM timeline WHERE statusId <= (SELECT statusId FROM timeline ORDER BY statusId DESC LIMIT 1 OFFSET 4000);"
"DELETE FROM statuses WHERE statusId NOT IN (SELECT statusId FROM timeline) and statusId NOT IN (SELECT statusId FROM favorites) and statusId NOT IN (SELECT statusId FROM mentions) and statusId NOT IN (SELECT statusId FROM comments);"
"COMMIT";


const char *optimize_sql = "VACUUM; ANALYZE";

+ (void)closeDatabase
{
    char *errmsg;
    if (theDatabase) {
		/*
        if (sqlite3_exec(theDatabase, cleanup_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
            // ignore error
            DLog(@"Error: failed to cleanup chache (%s)", errmsg);
        }
		 */
        
      	NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
        DLog(@"launchCount %d", (int)launchCount);
        if (launchCount-- <= 0) {
            DLog(@"Optimize database...");
            if (sqlite3_exec(theDatabase, optimize_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
                DLog(@"Error: failed to cleanup chache (%s)", errmsg);
            }
            launchCount = 50;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        sqlite3_close(theDatabase);
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
        
    if (force) {
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    
    // No exists any database file. Create new one.
    //
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

+ (void)beginTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "BEGIN", NULL, NULL, &errmsg);     
}

+ (void)commitTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "COMMIT", NULL, NULL, &errmsg);     
}

+ (Statement*)statementWithQuery:(const char *)sql
{
    Statement* stmt = [Statement statementWithDB:theDatabase query:sql];
    return stmt;
}

+ (Statement*)statementWithQueryString:(NSString *)sqlstr
{
    const char *sql = sqlstr.UTF8String;
    Statement* stmt = [Statement statementWithDB:theDatabase query:sql];
    return stmt;
}

+ (void)alert
{
#ifdef DEBUG
    NSString *sqlite3err = [NSString stringWithUTF8String:sqlite3_errmsg(theDatabase)];
    DLog(@"sqlite3err: %@",sqlite3err);
#endif
}

@end
