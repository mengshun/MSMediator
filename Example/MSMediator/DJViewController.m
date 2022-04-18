//
//  DJViewController.m
//  MSMediator
//
//  Created by shun.meng on 05/24/2021.
//  Copyright (c) 2021 shun.meng. All rights reserved.
//

#import "DJViewController.h"
#import "DJRouterHeader.h"

@interface DJViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *dataList;

@end

@implementation DJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"首页";
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *vc = nil;
    switch (indexPath.row) {
        case 0:
        {
            vc = [DJ() aDetailVC:nil];
        }
            break;
        case 1:
        {
            vc = [DJ() bDetailVCTitle:@"设置标题" prdId:@"ABC" params:nil];
        }
            break;
        case 2:
        {
            vc = [DJ() performActionWithUrl:[NSURL URLWithString:@"dj://a/detail"] completion:nil];
        }
            break;
        case 3:
        {
            NSString *jumpUrl = @"dj://b/detail?title=改变标题了&prdId=1234";
            vc = [DJ() performActionWithUrl:[jumpUrl dj_URL] completion:nil];
        }
            break;
        case 4:
        {
            [DJ() login];
        }
            break;
        case 5:
        {
            [DJ() login:^{
                NSLog(@"收到登录成功了");
            }];
        }
            break;
        case 6:
        {
            [DJ() jumpWithURLString:@"dj://login" params:nil];
        }
            break;
        case 7:
        {
            [DJ() performActionWithUrl:[@"dj://login1" dj_URL] completion:nil];
        }
            break;
        case 8:
        {
            [DJ() performActionWithUrl:[@"dj://c/go" dj_URL] completion:nil];
        }
            break;
        default:
            break;
    }
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Getter Method

- (NSArray *)dataList
{
    if (!_dataList) {
        _dataList = @[@"1. 本地跳转A",
                      @"2. 本地跳转B",
                      @"3. 远端跳转A dj://a/detail",
                      @"4. 远端跳转B dj://b/detail?title=改变标题了&prdId=1234",
                      @"5. 拉起登录 无返回值",
                      @"6. 拉起登录 含返回值",
                      @"7. 不含path URL: dj://login",
                      @"8. 非法调用: dj://login1",
                      @"9. 非法调用: dj://c/go",
        ];
    }
    return _dataList;
}

@end
