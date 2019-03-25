//
//  TestUnrecoginzedVC.m
//  QYCrashProtector
//
//  Created by QFMac-02 on 2019/3/21.
//  Copyright © 2019 qiye. All rights reserved.
//

#import "TestUnrecoginzedVC.h"
@interface TestUnrecoginzedVC ()

@end

@implementation TestUnrecoginzedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self unrecoginzedVC];
    [self arrayCrash];
    
    // Do any additional setup after loading the view.
}

-(void)unrecoginzedVC{
    UIButton *btn =  [UIButton new];
    btn.frame = CGRectMake(100, 100, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(tochMe:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
//NSArray crash
-(void)arrayCrash{
        NSString * tt  = nil;
        NSArray * arr = @[@"111",@"222",tt,@"ddd"];
//        NSArray * arr2 = @[@[@"aa",@"bb"],@[@"dd",tt]];
//        NSArray *arr3 = [NSArray arrayWithObjects:@"dsd",tt,@"sdsd", nil];
        NSLog(@"输出-------%@",arr[6]);
}
//NSMutableArr crash
-(void)mutableCrash{
    NSString * tt  = nil;
    NSMutableArray * arr4 = [NSMutableArray array];
    // [arr4 objectAtIndex:5];
    [arr4 addObject:tt];
}
//-(void)tochMe:(UIButton*)sender{
//    NSLog(@"dianwoyayayayyayayyay");
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
