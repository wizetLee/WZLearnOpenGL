//
//  ViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 22/8/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "ViewController.h"

#pragma mark - 就是加入这个文件
#import "WZLearnOpenGL-Swift.h"

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
                 @{@"title" : @"EViewController", @"attachment" : @"多重纹理"},
                 @{@"title" : @"FViewController", @"attachment" : @"Swift多重纹理"},
//                 @{@"title" : @"FViewController", @"attachment" : @"纹理"},
                  @{@"title" : @"IViewController", @"attachment" : @"GLSL"},
                 @{@"title" : @"LViewController", @"attachment" : @"多个着色器程序"},
                 @{@"title" : @"MViewController", @"attachment" : @"多个着色器程序"},
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
    UIViewController *VC = nil;
    NSString *classStr = _dataArr[indexPath.row][@"title"];
   
#pragma mark - 暂时找不到方法  swift类名转为Class类型 直接转的都是0x0 _ nil
    if ([classStr isEqualToString:@"FViewController"]) {
        VC = FViewController.alloc.init;
        [(FViewController *)VC saySomething];
    } else//暂时找不到方法  swift类名转为Class类型 直接转的都是0x0 _ nil
    if ([classStr isEqualToString:@"GViewController"]) {
        VC = GViewController.alloc.init;
        
    }  else {
        Class class = NSClassFromString(classStr);
        if (class) {
            VC = [class new];
        }
    }
    
    if ([VC isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:VC animated:true];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
