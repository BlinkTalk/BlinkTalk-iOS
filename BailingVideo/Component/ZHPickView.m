//
//  ZHPickView.m
//  BlinkTalk
//
//  Created by LiuLinhong on 16/11/11.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "ZHPickView.h"
#define ZHToobarHeight 40

@interface ZHPickView () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, copy) NSString *plistName;
@property (nonatomic, strong) NSArray *plistArray;
@property (nonatomic, assign) BOOL isLevelArray;
@property (nonatomic, assign) BOOL isLevelString;
@property (nonatomic, assign) BOOL isLevelDic;
@property (nonatomic, strong) NSDictionary *levelTwoDic;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, assign) NSDate *defaulDate;
@property (nonatomic, assign) BOOL isHaveNavControler;
@property (nonatomic, assign) NSInteger pickeviewHeight;
@property (nonatomic, copy) NSString *resultString;
@property (nonatomic, strong) NSMutableArray *componentArray;
@property (nonatomic, strong) NSMutableArray *dicKeyArray;
@property (nonatomic, strong) NSMutableArray *state;
@property (nonatomic, strong) NSMutableArray *city;
@property (nonatomic, assign) NSInteger selectPickerRow;

@end


@implementation ZHPickView

- (NSArray *)plistArray
{
    if (!_plistArray)
    {
        _plistArray = [[NSArray alloc] init];
    }
    return _plistArray;
}

- (NSArray *)componentArray
{
    
    if (!_componentArray)
    {
        _componentArray = [[NSMutableArray alloc] init];
    }
    return _componentArray;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUpToolBar];
    }
    return self;
}

- (instancetype)initPickviewWithPlistName:(NSString *)plistName isHaveNavControler:(BOOL)isHaveNavControler
{
    self = [super init];
    if (self)
    {
        _plistName = plistName;
        self.plistArray = [self getPlistArrayByplistName:plistName];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

- (instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler
{
    self = [super init];
    if (self)
    {
        self.plistArray = array;
        [self setArrayClass:array];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

- (instancetype)initDatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler
{
    self = [super init];
    if (self)
    {
        _defaulDate = defaulDate;
        [self setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

- (instancetype)initPickerWithMinValue:(NSInteger)min max:(NSInteger)max defaultValue:(NSInteger)defaultValue step:(NSInteger)step isHaveNavControler:(BOOL)isHaveNavControler
{
    self = [super init];
    if (self)
    {
        NSMutableArray *muArray = [NSMutableArray array];
        for (NSInteger temp = min; temp <= max; temp += step)
            [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];
        
        self.plistArray = muArray;
        [self setArrayClass:muArray];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
        
        NSInteger defaultIndex = [muArray indexOfObject:[NSString stringWithFormat:@"%zd", defaultValue]];
        [self setSelectedPickerItem:defaultIndex];
    }
    return self;
}

- (void)setMin:(NSInteger)min max:(NSInteger)max defaultValue:(NSInteger)defaultValue step:(NSInteger)step
{
    NSMutableArray *muArray = [NSMutableArray array];
    for (NSInteger temp = min; temp <= max; temp += step)
        [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];
    
    self.plistArray = muArray;
    [self setArrayClass:muArray];
    [_pickerView reloadAllComponents];
    NSInteger defaultIndex = [muArray indexOfObject:[NSString stringWithFormat:@"%zd", defaultValue]];
    [self setSelectedPickerItem:defaultIndex];
}

- (NSArray *)getPlistArrayByplistName:(NSString *)plistName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
    [self setArrayClass:array];
    return array;
}

- (void)setArrayClass:(NSArray *)array
{
    _dicKeyArray = [[NSMutableArray alloc] init];
    for (id levelTwo in array)
    {
        if ([levelTwo isKindOfClass:[NSArray class]])
        {
            _isLevelArray = YES;
            _isLevelString = NO;
            _isLevelDic = NO;
        }
        else if ([levelTwo isKindOfClass:[NSString class]])
        {
            _isLevelString = YES;
            _isLevelArray = NO;
            _isLevelDic = NO;
        }
        else if ([levelTwo isKindOfClass:[NSDictionary class]])
        {
            _isLevelDic = YES;
            _isLevelString = NO;
            _isLevelArray = NO;
            _levelTwoDic = levelTwo;
            [_dicKeyArray addObject:[_levelTwoDic allKeys]];
        }
    }
}

- (void)setFrameWith:(BOOL)isHaveNavControler
{
    CGFloat toolViewX = 0;
    CGFloat toolViewH = _pickeviewHeight + ZHToobarHeight;
    CGFloat toolViewY;
    if (isHaveNavControler)
    {
        toolViewY = [UIScreen mainScreen].bounds.size.height - toolViewH-50;
    }
    else
    {
        toolViewY = [UIScreen mainScreen].bounds.size.height - toolViewH;
    }
    CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(toolViewX, toolViewY, toolViewW, toolViewH);
}

- (void)setUpPickView
{
    UIPickerView *pickView = [[UIPickerView alloc] init];
    pickView.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0];
    _pickerView = pickView;
    pickView.delegate = self;
    pickView.dataSource = self;
    pickView.frame = CGRectMake(0, ZHToobarHeight, ScreenWidth, pickView.frame.size.height);
    _pickeviewHeight = pickView.frame.size.height;
    [self addSubview:pickView];
}

- (void)setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    datePicker.datePickerMode = datePickerMode;
    datePicker.backgroundColor = [UIColor lightGrayColor];
    if (_defaulDate)
    {
        [datePicker setDate:_defaulDate];
    }
    _datePicker = datePicker;
    datePicker.frame = CGRectMake(0, ZHToobarHeight, datePicker.frame.size.width, datePicker.frame.size.height);
    _pickeviewHeight = datePicker.frame.size.height;
    [self addSubview:datePicker];
}

- (void)setUpToolBar
{
    _toolbar = [self setToolbarStyle];
    _toolbar.frame = CGRectMake(0, 0, ScreenWidth-0, ZHToobarHeight);
    [self addSubview:_toolbar];
}

- (UIToolbar *)setToolbarStyle
{
    CGFloat blankSpaceWidth = 10;
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, blankSpaceWidth, ZHToobarHeight)]];
    
    UIBarButtonItem *lefttem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"setting_Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    
    UIBarButtonItem *centerSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"setting_OK", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];

    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - blankSpaceWidth, 0, blankSpaceWidth, ZHToobarHeight)]];
    
    toolbar.items = @[leftSpace, lefttem, centerSpace, right, rightSpace];
    return toolbar;
}

#pragma mark - piackViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger component = 0;
    if (_isLevelArray)
        component=_plistArray.count;
    else if (_isLevelString)
        component=1;
    else if(_isLevelDic)
        component=[_levelTwoDic allKeys].count*2;
    
    return component;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *rowArray = [[NSArray alloc] init];
    if (_isLevelArray)
        rowArray = _plistArray[component];
    else if (_isLevelString)
        rowArray = _plistArray;
    else if (_isLevelDic)
    {
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic = _plistArray[pIndex];
        for (id dicValue in [dic allValues])
        {
            if ([dicValue isKindOfClass:[NSArray class]])
            {
                if (component % 2 == 1)
                    rowArray = dicValue;
                else
                    rowArray = _plistArray;
            }
        }
    }
    return rowArray.count;
}

#pragma mark - UIPickerViewdelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *rowTitle = nil;
    if (_isLevelArray)
        rowTitle = _plistArray[component][row];
    else if (_isLevelString)
        rowTitle = _plistArray[row];
    else if (_isLevelDic)
    {
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic = _plistArray[pIndex];
        if(component%2 == 0)
        {
            rowTitle = _dicKeyArray[row][component];
        }
        for (id aa in [dic allValues])
        {
            if ([aa isKindOfClass:[NSArray class]] && component % 2 == 1)
            {
                NSArray *bb = aa;
                if (bb.count > row)
                    rowTitle = aa[row];
            }
        }
    }
    return rowTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectPickerRow = row;
    if (_isLevelDic && component % 2 == 0)
    {
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
    
    if (_isLevelString)
        _resultString = _plistArray[row];
    else if (_isLevelArray)
    {
        _resultString = @"";
        if (![self.componentArray containsObject:@(component)])
            [self.componentArray addObject:@(component)];
        
        for (int i = 0; i < _plistArray.count; i++)
        {
            if ([self.componentArray containsObject:@(i)])
            {
                NSInteger cIndex = [pickerView selectedRowInComponent:i];
                _resultString = [NSString stringWithFormat:@"%@%@", _resultString, _plistArray[i][cIndex]];
            }
            else
            {
                _resultString = [NSString stringWithFormat:@"%@%@", _resultString, _plistArray[i][0]];
            }
        }
    }
    else if (_isLevelDic)
    {
        if (component == 0)
            _state = _dicKeyArray[row][0];
        else
        {
            NSInteger cIndex = [pickerView selectedRowInComponent:0];
            NSDictionary *dicValueDic = _plistArray[cIndex];
            NSArray *dicValueArray = [dicValueDic allValues][0];
            if (dicValueArray.count > row)
                _city = dicValueArray[row];
        }
    }
}

- (void)remove
{
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(toolbarCancelBtnHaveClick:)])
    {
        [self.delegate toolbarCancelBtnHaveClick:self];
    }
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)doneClick
{
    if (_pickerView)
    {
        if (_resultString)
        {
        }
        else
        {
            if (_isLevelString)
            {
                _resultString = [NSString stringWithFormat:@"%@", _plistArray[0]];
            }
            else if (_isLevelArray)
            {
                _resultString = @"";
                for (int i = 0; i < _plistArray.count; i++)
                {
                    _resultString = [NSString stringWithFormat:@"%@%@", _resultString, _plistArray[i][0]];
                }
            }
            else if (_isLevelDic)
            {
                if (!_state)
                {
                    _state =_dicKeyArray[0][0];
                    NSDictionary *dicValueDic = _plistArray[0];
                    _city = [dicValueDic allValues][0][0];
                }
                if (!_city)
                {
                    NSInteger cIndex = [_pickerView selectedRowInComponent:0];
                    NSDictionary *dicValueDic = _plistArray[cIndex];
                    _city = [dicValueDic allValues][0][0];
                }
                _resultString = [NSString stringWithFormat:@"%@%@", _state,_city];
            }
        }
    }
    else if (_datePicker)
        _resultString = [NSString stringWithFormat:@"%@", _datePicker.date];
    
    if ([self.delegate respondsToSelector:@selector(toolbarDonBtnHaveClick:resultString:selectedRow:)])
    {
        [self.delegate toolbarDonBtnHaveClick:self resultString:_resultString selectedRow:self.selectPickerRow];
    }
    [self removeFromSuperview];
}

/**
 *  设置PickView的颜色
 */
- (void)setPickViewColer:(UIColor *)color
{
    _pickerView.backgroundColor = color;
}

/**
 *  设置toobar的文字颜色
 */
- (void)setTintColor:(UIColor *)color
{
    _toolbar.tintColor = color;
}

/**
 *  设置toobar的背景颜色
 */
- (void)setToolbarTintColor:(UIColor *)color
{
    _toolbar.barTintColor = color;
}

- (void)setSelectedPickerItem:(NSInteger)index
{
    self.selectPickerRow = index;
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _resultString = _plistArray[index];
}

- (void)dealloc
{
}

@end
