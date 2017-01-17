//
//  MCViewController.m
//  简书userCenter
//
//  Created by 周陆洲 on 16/4/19.
//  Copyright © 2016年 MuChen. All rights reserved.
//

#import "MCViewController.h"
#import "MainView.h"
#import "MCCustomBar.h"
#import "DynamicView.h"
#import "ArticleView.h"
#import "MoreView.h"

#define ItemTintColor MCColor(227, 116, 98, 1)
#define ItemNorTintColor MCColor(160, 160, 160, 1)

const CGFloat headW = 70;
const CGFloat navH = 64;
const CGFloat sectionBarH = 46;

@interface MCViewController()<UIScrollViewDelegate,UITableViewDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *sectionView;
@property (nonatomic, strong) UIImageView *userHead;
@property (nonatomic, weak)UIScrollView *tableScrollView; //tableView滑动

@property (nonatomic, strong) DynamicView *dynamicView;
@property (nonatomic, strong) ArticleView *articleView;
@property (nonatomic, strong) MoreView *moreView;

@end

@implementation MCViewController
{
    MCCustomBar *_dynamicBar;    //动态
    MCCustomBar *_articleBar; //文章
    MCCustomBar *_moreBar;     //更多
    
    UIView *_bottomLine;
    UIView *_movingLine;
    NSInteger _index;
    CGFloat _tableViewH;
    CGFloat _lastOffset;
    CGFloat _yOffset;
    CGFloat _changW;
    CGFloat _changY;
    UIImage *_headImage;
    BOOL _isUp;
}

-(void)viewDidLoad{
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.bounds = CGRectMake(0, 34, 50, 30);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    [self createTableScrollView];
    
    [self createHeaderView];
    
    [self createUserHead];

}
- (void)backBtnClick{
    NSLog(@"\n返回");
}
#pragma mark 创建上方头视图
-(void)createHeaderView{
    CGFloat margin = 80;
    CGFloat labelW = SCREEN_WIDTH - 2*margin;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 246)];
    _headerView.backgroundColor = MCColor(252, 252, 252, 1);
    _yOffset = _headerView.centerY;
    //昵称
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, 50, labelW, 30)];
    userNameLabel.textAlignment = NSTextAlignmentCenter;
    userNameLabel.font = MCBlodFont(18);
    userNameLabel.text = @"M_慕宸";
    [_headerView addSubview:userNameLabel];
    
    //简介描述
    UILabel *describeLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(userNameLabel.frame)+2, labelW, 24)];
    describeLabel.textAlignment = NSTextAlignmentCenter;
    describeLabel.font = MCBlodFont(13);
    [describeLabel setTextColor:[UIColor lightGrayColor]];
    describeLabel.text = @"iOS程序员";
    [_headerView addSubview:describeLabel];
    
    //详细
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(describeLabel.frame)+2, labelW, 24)];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.font = MCBlodFont(13);
    [detailLabel setTextColor:[UIColor lightGrayColor]];
    detailLabel.text = @"写了0字，获得0个喜欢";
    [_headerView addSubview:detailLabel];
    
    //关注按钮
    CGFloat btnW = 96;
    CGFloat btnH = 32;
    UIButton *attationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    attationBtn.bounds = CGRectMake(0, 0, btnW, btnH);
    attationBtn.center = CGPointMake(self.view.center.x, CGRectGetMaxY(detailLabel.frame)+26);
    attationBtn.layer.cornerRadius = 4;
    attationBtn.layer.borderWidth = 0.8;
    attationBtn.layer.borderColor = MCColor(64, 189, 38, 1).CGColor;
    [attationBtn setTitleColor:MCColor(64, 189, 38, 1) forState:UIControlStateNormal];
    attationBtn.titleLabel.font = MCBlodFont(13);
    [attationBtn setTitle:@"关注／已关注" forState:UIControlStateNormal];
    [attationBtn addTarget:self action:@selector(attationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:attationBtn];
    
    [self createSectionView];
    
    [self.view addSubview:_headerView];
  
}

#pragma mark 创建下方tableview
-(void)createTableScrollView{
    CGFloat tableScrollX = 0;
    CGFloat tableScrollY = 0;
    CGFloat tableScrollWidth = SCREEN_WIDTH;
    CGFloat tableScrollHeight = SCREEN_HEIGHT-navH;
    
    UIScrollView *tableScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(tableScrollX, tableScrollY, tableScrollWidth, tableScrollHeight)];
    tableScrollView.delegate = self;
    tableScrollView.contentSize = CGSizeMake(3*SCREEN_WIDTH, tableScrollHeight);
    tableScrollView.pagingEnabled = YES;
    tableScrollView.alwaysBounceVertical = NO;
    tableScrollView.bounces = NO;
    _tableScrollView = tableScrollView;
    
    //动态
    _dynamicView = [[DynamicView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableScrollHeight)];
    _dynamicView.tableview.tag = 100;
    _dynamicView.tableview.delegate = self;
    [self createTableHeadView:_dynamicView.tableview];
    [_tableScrollView addSubview:_dynamicView];
   
    //文章tableView
    _articleView = [[ArticleView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH,tableScrollHeight)];
    _articleView.tableview.tag = 101;
    _articleView.tableview.delegate = self;
    [self createTableHeadView:_articleView.tableview];
    [_tableScrollView addSubview:_articleView];
    
    //更多tableView
    _moreView = [[MoreView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, tableScrollHeight)];
    _moreView.tableview.tag = 102;
    _moreView.tableview.delegate = self;
    [self createTableHeadView:_moreView.tableview];
    [_tableScrollView addSubview:_moreView];
    [self.view addSubview:_tableScrollView];
    //初始化数据
     [self loadDataWithIndex:0];
}

-(void)createTableHeadView:(UITableView *)tableView{
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 246)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.tableHeaderView = tableHeaderView;
    tableView.backgroundColor = MCColor(252, 252, 252, 1);
}


-(void)attationBtnClick:(UIButton *)btn{
    NSLog(@"\n点击关注");
    [_dynamicView.tableview reloadData];
}

#pragma mark 创建段头
-(void)createSectionView{
    _sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, sectionBarH)];
    _sectionView.backgroundColor = [UIColor whiteColor];
    
    //划线
    UIView *topLine = [ToolMothod createLineWithWidth:SCREEN_WIDTH andHeight:1 andColor:MCColor(234, 234, 234, 1.0)];
    [topLine setOrigin:CGPointMake(0,0)];
    [_sectionView addSubview:topLine];
    
    CGFloat ControlBarWidth = VIEW_WEDTH/3;
    CGFloat ControlBarheight = 30;
    CGFloat ControlBarY =  CGRectGetMaxY(topLine.frame) + 7;
    CGSize barSize = CGSizeMake(ControlBarWidth, ControlBarheight);
    
    //动态bar
    _dynamicBar = [[MCCustomBar alloc]initWithCount:@"0" andName:@"动态" size:barSize];
    [_dynamicBar addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    _dynamicBar.tag = 0;
    _dynamicBar.nameLabel.textColor = ItemTintColor;
    [_dynamicBar setOrigin:CGPointMake(0, ControlBarY)];
    
    [_sectionView addSubview:_dynamicBar];
    //文章bar
    _articleBar = [[MCCustomBar alloc]initWithCount:@"0" andName:@"文章" size:barSize];
    [_articleBar addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    _articleBar.tag = 1;
    [_articleBar setOrigin:CGPointMake(ControlBarWidth, ControlBarY)];
    [_sectionView addSubview:_articleBar];
    //更多bar
    _moreBar = [[MCCustomBar alloc]initWithCount:@"0" andName:@"更多" size:barSize];
    [_moreBar addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    _moreBar.tag = 2;
    [_moreBar setOrigin:CGPointMake(2*ControlBarWidth, ControlBarY)];
    [_sectionView addSubview:_moreBar];
    
    //划线
    _bottomLine = [ToolMothod createLineWithWidth:SCREEN_WIDTH andHeight:1 andColor:MCColor(234, 234, 234, 1.0)];
    [_bottomLine setOrigin:CGPointMake(0, CGRectGetMaxY(_dynamicBar.frame) + 8)];
    [_sectionView addSubview:_bottomLine];
    
    //创建移动下划线
    _movingLine = [ToolMothod createLineWithWidth:35 andHeight:2 andColor:ItemTintColor];
    _movingLine.center = CGPointMake(_dynamicBar.centerX, 0);
    [_bottomLine addSubview:_movingLine];

    [_headerView addSubview:_sectionView];
}

- (void)changeView :(MCCustomBar *)sender{
    
    _index = sender.tag;
    [self moveLine:_index];
    
    if ([_dynamicBar isEqual:sender]) {
        
        [self changeItemTintColor:(MCCustomBar *)sender];
        [_tableScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        _dynamicBar.nameLabel.textColor = ItemTintColor;
        _articleBar.selected = NO;
        _moreBar.selected = NO;
         [self loadDataWithIndex:0];
    }else if ([_articleBar isEqual:sender]){
        
        [self changeItemTintColor:(MCCustomBar *)sender];
        [_tableScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
        _articleBar.nameLabel.textColor = ItemTintColor;
        _dynamicBar.selected = NO;
        _moreBar.selected = NO;
         [self loadDataWithIndex:1];
    }else if ([_moreBar isEqual:sender]){
        
        [self changeItemTintColor:(MCCustomBar *)sender];
        [_tableScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*2, 0) animated:NO];
        _moreBar.nameLabel.textColor = ItemTintColor;
        _dynamicBar.selected = NO;
        _articleBar.selected = NO;
         [self loadDataWithIndex:2];
    }
}

#pragma mark 创建头像
-(void)createUserHead{

    CGFloat centerX = self.view.centerX;
    _userHead = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head.jpg"]];
    _userHead.layer.cornerRadius = 35.0;
    _userHead.layer.masksToBounds = YES;
    _userHead.size = CGSizeMake(headW, headW);
    _userHead.origin = CGPointMake(centerX - 35.0, 9.0);
    [self.navigationController.navigationBar addSubview:_userHead];
}

-(void)moveLine:(NSInteger)sender
{
    CGFloat lineX;
    if (sender == 0) {
        lineX = _dynamicBar.centerX;
    }else if (sender == 1){
        lineX = _articleBar.centerX;
    }else{
        lineX = _moreBar.centerX;
    }
    [UIView animateWithDuration:0.2 animations:^{
        
        _movingLine.center = CGPointMake(lineX, 0);
    }];
}

-(void)changeItemTintColor:(MCCustomBar *)sender
{
    if (![_dynamicBar isEqual:sender]) {
        
        _dynamicBar.nameLabel.textColor = ItemNorTintColor;
        
    }
    if (![_articleBar isEqual:sender]){
        
        _articleBar.nameLabel.textColor = ItemNorTintColor;
    }
    if (![_moreBar isEqual:sender]){
        
        _moreBar.nameLabel.textColor = ItemNorTintColor;
    }
}

#pragma mark scrollView
//不知道为什么滑动的时候，慢的时候头像缩放还OK，但快的时候，就出现问题。。。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isEqual:_tableScrollView]) {
        _index = _tableScrollView.bounds.origin.x/_tableScrollView.bounds.size.width;
        [self moveLine:_index];
       
    }
    else{
         CGFloat offsetY = scrollView.contentOffset.y;
         CGFloat  scale = MAX(0.45, 1.0 - offsetY / 200.0);
        CGFloat h = _yOffset - offsetY;
        NSLog(@"************* %f",scale);
  
        
        [UIView animateWithDuration:0.1 animations:^{
            // 放大
            if (offsetY < 201){
                // 缩小
                // 允许向上超过导航条缩小的最大距离为200
                // 为了防止缩小过度，给一个最小值为0.45，其中0.45 = 31.5 / 70.0，表示
                // 头像最小是31.5像素

                    _userHead.transform = CGAffineTransformMakeScale(scale, scale);
                    // 保证缩放后y坐标不变
                    CGRect frame = _userHead.frame;
                    frame.origin.y = 5;
                    _userHead.frame = frame;
            }
           
            
        }completion:^(BOOL finished) {
            if (finished) {
                // 放大
                if (offsetY < 0) {

                    _headerView.center = CGPointMake(_headerView.center.x, h);
                    
                }
                else if (offsetY < 201){
                    // 缩小
                    // 允许向上超过导航条缩小的最大距离为200
                    // 为了防止缩小过度，给一个最小值为0.45，其中0.45 = 31.5 / 70.0，表示
                    // 头像最小是31.5像素

                    _headerView.center = CGPointMake(_headerView.center.x, h);
                
                }
                else{
                  
                    _headerView.center = CGPointMake(_headerView.center.x, _yOffset - 200);
                
                }
  
            }
        }];
        
    }

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if ([scrollView isEqual:_tableScrollView]) {
        
        if (_index == 0) {
            [self changeView:_dynamicBar];
        }else if (_index == 1){
            [self changeView:_articleBar];
        }else if (_index == 2){
            [self changeView:_moreBar];
        }
        
        return;
    }
    
    [self setTableViewContentOffsetWithTag:scrollView.tag contentOffset:scrollView.contentOffset.y];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:_tableScrollView]) {
        return;
    }
    [self setTableViewContentOffsetWithTag:scrollView.tag contentOffset:scrollView.contentOffset.y];
}

//设置tableView的偏移量
-(void)setTableViewContentOffsetWithTag:(NSInteger)tag contentOffset:(CGFloat)offset{
    
    CGFloat tableViewOffset = offset;
    if(offset > 200){
        
        tableViewOffset = 200;
    }
    if (tag == 100) {
        [_articleView.tableview setContentOffset:CGPointMake(0, tableViewOffset) animated:NO];
        [_moreView.tableview setContentOffset:CGPointMake(0, tableViewOffset) animated:NO];
        
    }else if(tag == 101){
        
        [_dynamicView.tableview setContentOffset:CGPointMake(0, tableViewOffset) animated:NO];
        [_moreView.tableview setContentOffset:CGPointMake(0, tableViewOffset) animated:NO];
        
    }else{
        
        [_dynamicView.tableview setContentOffset:CGPointMake(0, tableViewOffset) animated:NO];
        [_articleView.tableview setContentOffset:CGPointMake(0, tableViewOffset) animated:NO];
        
    }
}
- (void)loadDataWithIndex:(int)index{
    NSMutableArray *dataArr = [NSMutableArray array];
    static int j = 100;
    for (int i = 0; i < 20; i ++) {
        if (index == 0) {
            NSString *str =  [NSString stringWithFormat:@"DynamicView%d---%d",j,i];
            [dataArr addObject:str];
        }
        else if(index == 1){
            NSString *str =  [NSString stringWithFormat:@"ArticleView%d---%d",j,i];
            [dataArr addObject:str];
        }
        else{
            NSString *str =  [NSString stringWithFormat:@"MoreView%d---%d",j,i];
            [dataArr addObject:str];
        }
        
    }
    if (index == 0) {
        _dynamicView.dataSource = dataArr;
        [_dynamicView.tableview reloadData];
    }
    else if (index == 1){
        _articleView.dataSource = dataArr;
         [_articleView.tableview reloadData];
    }
    else{
        _moreView.dataSource = dataArr;
         [_moreView.tableview reloadData];
    }
    j ++;
}


@end










