//
//  BaiduMapViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MapViewController.h"
#import "BaseTableViewCell.h"
#import "UIButton+NSIndexPath.h"
#import "BasicNavigationController.h"
#import "CameraActionSheet.h"
#import "SessionNewController.h"
#import "Session.h"
#import "JSON.h"
#import "Message.h"
#import "TalkingViewController.h"
#import "ImageTouchView.h"
#import "TextInput.h"

@interface MapViewController ()<BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate, CameraActionSheetDelegate, BMKPoiSearchDelegate,BMKMapViewDelegate> {
    BMKMapView              * _mapView;
    BMKLocationService      * _locService;
    BMKGeoCodeSearch        * _geoCodesearch;
    BMKAnnotationView       * newAnnotation;
    
    CLLocationCoordinate2D  myLocation;
    BOOL                    located;
    NSString                * resultAddress;
    UIActivityIndicatorView * activityIndicator;
    NSIndexPath             * selectedIndexPath;
    
    BMKPoiSearch            * _bMKPoiSearch;
}

@end

@implementation MapViewController

- (id)initWithDelegate:(id <MapViewDelegate>)del
{
    if (self = [super init]) {
        // Custom initialization
        self.delegate = del;
        self.readOnly = NO;
        enablefilter = YES;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        // Custom initialization
        self.readOnly = YES;
    }
    return self;
}

- (void)dealloc {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    located = NO;
    self.navigationItem.title = @"位置";
    if (_readOnly) {
        self.pointAnnotation = [[BMKPointAnnotation alloc] init];
    }
    _geoCodesearch = [[BMKGeoCodeSearch alloc] init];
    _locService = [[BMKLocationService alloc]init];
    _bMKPoiSearch = [[BMKPoiSearch alloc] init];
    
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
    
    // 如果不是只读，则加载更多选项
    if (!_readOnly) {
//        _mapView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        self.navigationItem.titleView = self.titleView;
        tableView.top = _mapView.bottom;
        tableView.height = self.view.height - _mapView.height;
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [activityIndicator setCenter:tableView.center];
        activityIndicator.top = tableView.height/3;
        activityIndicator.color = kbColor;
        [tableView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [self.view insertSubview:_mapView belowSubview:filterTableView];
    } else {
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        if (Sys_Version >= 7) {
            _mapView.top += 64;
            _mapView.height = self.view.height - 64;
        } else {
            _mapView.height = self.view.height;
        }
        [self.view addSubview:_mapView];
        myLocation.latitude = _location.lat;
        myLocation.longitude = _location.lng;
        [self setRightBarButtonImage:LOADIMAGE(@"btn_more") highlightedImage:LOADIMAGE(@"btn_more_d") selector:@selector(morePressed)];
    }
    
    self.searchView.width = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geoCodesearch.delegate = self;
    _locService.delegate = self;
    _bMKPoiSearch.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    [_locService stopUserLocationService];
    _mapView.delegate = nil; // 不用时，置nil
    _geoCodesearch.delegate = nil;
    _locService.delegate = nil;
    _bMKPoiSearch.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        if (_readOnly) {
            located = YES;
            _mapView.minZoomLevel =
            _mapView.zoomLevel = 16;
            BMKCoordinateRegion region;
            region.center = myLocation;
            region.span = BMKCoordinateSpanMake(0.001, 0.001);
            [_mapView setRegion:region animated:YES];
            [_mapView setCenterCoordinate:myLocation animated:YES];
            if ([_delegate respondsToSelector:@selector(getCurrentSetLocationString)]) {
                _pointAnnotation.title = [_delegate getCurrentSetLocationString];
            } else {
                _pointAnnotation.title = _pointAnnotationTitle?_pointAnnotationTitle:@"我在这儿";
            }
            _pointAnnotation.coordinate = myLocation;
            [_mapView addAnnotation:_pointAnnotation];
        } else {
            self.navigationItem.title = @"位置";
        }
    }
    if (!_readOnly) {
        [_locService startUserLocationService];
    }
}

- (void)popViewController {
    if (self.searchView.width != 0) {
        [self imageTouchViewDidSelected:self.searchButton];
    } else {
        [super popViewController];
    }
}

- (void)individuationTitleView {
    self.addButton.tag = @"map_send";
    self.addButton.image = LOADIMAGE(@"map_send");
    self.addButton.left = self.titleView.width - 35;
    
    self.searchButton.image = LOADIMAGE(@"map_search");
    self.searchButton.left = self.titleView.width - 75;
}

- (void)morePressed {
    [[[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"发送给朋友", @"收藏", nil] show];
}

//停止定位
-(void)stopLocation
{
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}

#pragma mark - buttonMethods
- (void)commitPressed:(id)sender {
    if (!_readOnly) {
        if ([_delegate respondsToSelector:@selector(mapViewControllerSetLocation:content:)]) {
            [_delegate mapViewControllerSetLocation:kLocationMake(myLocation.latitude, myLocation.longitude) content:_currectPoiInfo.address];
        } else if ([_delegate respondsToSelector:@selector(mapViewControllerSetLocation:)]) {
            [_delegate mapViewControllerSetLocation:kLocationMake(myLocation.latitude, myLocation.longitude)];
        } else if ([_delegate respondsToSelector:@selector(mapViewControllerSetPoiInfo:)]) {
            if (self.currectPoiInfo) {
                [_delegate mapViewControllerSetPoiInfo:self.currectPoiInfo];
            }
        }
        [self popViewController];
    }
}

#pragma mark - BMKMapViewDelegate
/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi {
    DLog(@"%@",mapPoi.text);
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    [self commitPressed:nil];
    DLog(@"paopaoclick");
}
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {
	DLog(@"start locate");
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation {
	if (userLocation != nil) {
        if (!located) {
            located = YES;
            myLocation = userLocation.location.coordinate;
            _mapView.minZoomLevel =
            _mapView.zoomLevel = 16;
            _mapView.showsUserLocation = NO;
            BMKCoordinateRegion region;
            region.center = myLocation;
            region.span = BMKCoordinateSpanMake(0.001, 0.001);
            [_mapView setRegion:region animated:YES];
            [self getLocationString];
            [self stopLocation];
        }
	}
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView{
    DLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    DLog(@"location error");
}

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)sender
{
	if ([sender isKindOfClass:[BMKPointAnnotation class]]) {
        
        NSString *AnnotationViewID = @"renameMark";
        if (newAnnotation == nil) {
            newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:_pointAnnotation reuseIdentifier:AnnotationViewID];
            // 设置颜色
            ((BMKPinAnnotationView*)newAnnotation).pinColor = BMKPinAnnotationColorGreen;
            // 从天上掉下效果
            ((BMKPinAnnotationView*)newAnnotation).animatesDrop = NO;
            // 设置可拖拽
            ((BMKPinAnnotationView*)newAnnotation).draggable = NO;
        }
        return newAnnotation;
	}
	return nil;
}

/**
 *地图区域即将改变时会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (!_readOnly) {
        [_mapView removeAnnotation:_pointAnnotation];
    }
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (!_readOnly) {
        myLocation = mapView.centerCoordinate;
        [self getLocationString];
    }
}

//拖动annotation view时，若view的状态发生变化，会调用此函数。ios3.2以后支持
- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState
   fromOldState:(BMKAnnotationViewDragState)oldState {
    myLocation = view.annotation.coordinate;
    [self getLocationString];
}

/**
 *发送地理编码请求
 *@see reverseGeoCode
 */
- (void)getLocationString {
    //发起地理编码
    
    selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    BMKReverseGeoCodeOption *co = [[BMKReverseGeoCodeOption alloc] init];
    co.reverseGeoPoint = myLocation;
    [_geoCodesearch reverseGeoCode: co];
}

#pragma mark - BMKGeoCodeSearchDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    [activityIndicator stopAnimating];
    // 在此处添加您对地理编码结果的处理
    if (!self.currectPoiInfo) {
        self.currectPoiInfo = [[BMKPoiInfo alloc] init];
    }
    
    resultAddress = result.address;
    
    // add annotation
    //    pointAnnotation.title = result.address;
    //    pointAnnotation.coordinate = myLocation;
    //    if (![_mapView viewForAnnotation:pointAnnotation]) {
    //        [_mapView addAnnotation:pointAnnotation];
    
    UIImageView * pin = VIEWWITHTAG(_mapView, -1);
    if (!_readOnly && !pin) {
        pin = [[UIImageView alloc] initWithImage:LOADIMAGE(@"pin_green")];
        pin.tag = -1;
        pin.top = _mapView.height/2 - 30;
        pin.left = _mapView.width/2 - 15;
        [_mapView addSubview:pin];
    }
    //    }
    
    newAnnotation.hidden = NO;
    self.currectPoiInfo.pt = result.location;
    self.currectPoiInfo.address = result.address;
    self.city =
    self.currectPoiInfo.city = result.addressDetail.city;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.searchButton.alpha =
        self.addButton.alpha = 1;
    }];
    
    [contentArr removeAllObjects];
    BMKPoiInfo * poiInfo = [[BMKPoiInfo alloc] init];
    poiInfo.name = @"位置";
    poiInfo.pt = _currectPoiInfo.pt;
    poiInfo.address = _currectPoiInfo.address;
    [contentArr addObject:poiInfo];
    [contentArr addObjectsFromArray:result.poiList];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return inFilter?filterArr.count:contentArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"BaseHeadCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton * selectedView = VIEWWITHTAG(cell.contentView, 7);
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        selectedView = [UIButton buttonWithType:UIButtonTypeCustom];
        [cell.contentView addSubview:selectedView];
        selectedView.tag = 7;
        [selectedView setImage:LOADIMAGECACHES(@"CellNotSelected") forState:UIControlStateNormal];
        [selectedView setImage:LOADIMAGECACHES(@"CellGraySelected") forState:UIControlStateSelected];
    }
    selectedView.indexPath = indexPath;
    
    selectedView.selected = (selectedView.indexPath.row == selectedIndexPath.row);
    BMKPoiInfo * poiInfo = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    cell.textLabel.text = poiInfo.name;
    cell.detailTextLabel.text = poiInfo.address;
    cell.imageView.hidden = YES;
    [cell update:^(NSString *name) {
        cell.textLabel.frame = CGRectMake(10, 4, tableView.width - 40, cell.height/2);
        cell.detailTextLabel.frame = CGRectMake(10, cell.height/2 - 4, tableView.width - 40, cell.height/2);
        selectedView.frame = CGRectMake(cell.width - 22, (cell.height-12)/2, 12, 12);
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if (inFilter) {
        self.currectPoiInfo = [filterArr objectAtIndex:indexPath.row];
        myLocation = self.currectPoiInfo.pt;
        _mapView.zoomLevel = 16;
        BMKCoordinateRegion region = _mapView.region;
        region.center = myLocation;
        region.span = BMKCoordinateSpanMake(0.007, 0.007);
        [_mapView setRegion:region animated:YES];
        [self getLocationString];
        [self popViewController];
    } else {
        if (selectedIndexPath.row == indexPath.row) {
            return;
        }
        NSIndexPath * temp = [selectedIndexPath copy];
        selectedIndexPath = [indexPath copy];
        self.currectPoiInfo = [contentArr objectAtIndex:indexPath.row];
        [tableView reloadRowsAtIndexPaths:@[temp, indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma - mark CameraActionSheetDelegate
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self forwordWithMsg:self.value];
    } else if (buttonIndex == 1) {
        Message * it = self.value;
        it.state = forMessageStateHavent;
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:it.address.address forKey:@"address"];
        [dic setObject:[NSString stringWithFormat:@"%f", it.address.lat]  forKey:@"lat"];
        [dic setObject:[NSString stringWithFormat:@"%f", it.address.lng]  forKey:@"lng"];
        [dic setObject:[NSString stringWithFormat:@"%d", forFileAddress]  forKey:@"typefile"];
        NSString *otherid = (it.typechat != forChatTypeUser)?it.toId:nil;
        needToLoad = NO;
        [super startRequest];
        [self setLoading:YES content:@"收藏中"];
        [client addfavorite:it.fromId otherid:otherid content:[dic JSONString]];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}

#pragma mark - filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    BMKCitySearchOption * option = [[BMKCitySearchOption alloc] init];
    option.city = _city;
    option.keyword = searchText;
    [_bMKPoiSearch poiSearchInCity:option];
}

/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    [filterArr removeAllObjects];
    if (inFilter) {
        [filterArr addObjectsFromArray:poiResult.poiInfoList];
    }
    [filterTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"map_send"]) {
        if (self.searchView.width != 0) {
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
            [self.searchField resignFirstResponder];
        }else {
            if ([_delegate respondsToSelector:@selector(mapViewControllerSetPoiInfo:)]) {
                [_delegate mapViewControllerSetPoiInfo:self.currectPoiInfo];
                [self popViewController];
            }
        }
    } else {
        if ([sender.tag isEqualToString:@"none"]) {
            sender.tag = @"changed";
            [UIView animateWithDuration:0.3 animations:^{
                self.searchView.width = self.view.width - 65;
                self.searchButton.left = self.searchView.left + 5;
                self.addButton.left = self.titleView.width - 45;
                self.searchButton.image = LOADIMAGE(@"btn_search_d");
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
                self.searchView.alpha = 1;
            } completion:^(BOOL finished) {
                self.addButton.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:0.15 animations:^{
                    self.addButton.image = LOADIMAGE(@"btn_clear");
                    self.addButton.highlightedImage = LOADIMAGE(@"btn_clear_d");
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self.searchField becomeFirstResponder];
                    }
                }];
                
            }];
        } else {
            sender.tag = @"none";
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
            [UIView animateWithDuration:0.3 animations:^{
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
                self.searchButton.left = self.titleView.width - 75;
                self.searchView.width = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.addButton.transform = CGAffineTransformIdentity;
                    [UIView animateWithDuration:0.15 animations:^{
                        self.addButton.left = self.titleView.width - 35;
                        self.searchButton.image = LOADIMAGE(@"btn_search");
                        self.addButton.image = LOADIMAGE(@"map_send");
                        self.addButton.highlightedImage = nil;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [self.searchField resignFirstResponder];
                        }
                    }];
                }
            }];
        }
        
    }
}

@end
