//
//  ViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 22/8/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * table;
@property (nonatomic, strong) NSArray <NSDictionary *>*dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = false;
    [super viewDidLoad];
    _dataArr = @[@{@"title" : @"AViewController", @"attachment" : @"三角形"},
                 @{@"title" : @"BViewController", @"attachment" : @"纹理"},
                 @{@"title" : @"CViewController", @"attachment" : @"平铺模式"},
                 @{@"title" : @"DViewController", @"attachment" : @"纹理混合"},
                 @{@"title" : @"BViewController", @"attachment" : @"纹理"},
                 @{@"title" : @"BViewController", @"attachment" : @"纹理"},
                 @{@"title" : @"BViewController", @"attachment" : @"纹理"},
                 ];
    [self createViews];
}

- (void)createViews {
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64.0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 64.0) style:UITableViewStylePlain];
    [self.view addSubview:_table];
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"id"];
    _table.delegate = self;
    _table.dataSource = self;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr? _dataArr.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    cell.textLabel.text = [((NSString *)_dataArr[indexPath.row][@"title"]) stringByAppendingString:_dataArr[indexPath.row][@"attachment"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *classStr = _dataArr[indexPath.row][@"title"];
    Class class = NSClassFromString(classStr);
    if (class) {
        UIViewController *VC = [class new];
        if ([VC isKindOfClass:[UIViewController class]]) {
            [self.navigationController pushViewController:[class new] animated:true];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
