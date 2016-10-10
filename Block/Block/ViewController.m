//
//  ViewController.m
//  BlockMemeorySample
//
//  Created by Carouesl on 16/9/27.
//  Copyright © 2016年 Youku Tudou Inc. All rights reserved.
//

/**
                                iOS_Develop_Samples_Series-1
 
 这个示例主要介绍了block的三种类型 以及这三种类型的内存管理 和MRC ARC下的区别  主要是为了防止产生内存泄露和悬空指针问题
 
 */
#import "ViewController.h"
#import "Person.h"

typedef void(^myBlock)(id obj);

@interface ViewController ()

@property (nonatomic, copy) myBlock mBlcok;
@property (nonatomic, strong) NSMutableArray* myArray;
@property (nonatomic, strong) Person* person;
@property (nonatomic, assign) NSInteger number;
@end



@implementation ViewController



__weak id observerObject = nil; //全局变量 位于全局区或者叫静态去

int globalVar =  1;



- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.myArray = [NSMutableArray array];
        _number = 1000;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Block Smaple";
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(backToRoot)];
    self.view.backgroundColor = [UIColor whiteColor];
    //    int stackVar = 1;//1位于常量区  stackVar位于stack去
    //    NSString* stackStr = @"123"; //@"123"位于常量区   stackStr在栈区
    //    NSString* heapStr = [[NSString alloc] init]; //heapStr变量在栈区  指向的内存在堆区 参数都是保存在栈区
    
    
    /** brief
     首先block分为以下三种类型
     NSGlobalBlock：位于内存代码区
     NSStackBlock： 位于内存栈区
     NSMallocBlock：位于内存堆区
     对于block，有两个内存管理方法：Block_copy, Block_release;Block_copy与copy等效， Block_release与release等效；
     不管是对block进行retian,copy,release,block的引用计数都不会增加，始终为1；
     
     */
    
    
    /************ block类型以及内存问题  ************/
    
    { //折叠
        
        
#pragma __NSGlobalBlock__
        
        
        //无论ARC或者MRC 当blcok没有引用到外部变量的时或者引用到的变量是全局变量 此时block对象类型是__NSGlobalBlock__
        //这种类型的block的内存区为代码区  retain copy release都无效 在MRC下__NSStackBlock__同理 当它所在的函数返回后 栈内存会被系统回收  即使某个block被添加到数组或其他集合中也不能持有 因为stack的内存和text区的内存并不是以引用计数来判断的  内存的释放归属于系统
        
        void (^globalBlock) (NSInteger,NSInteger) = ^(NSInteger a, NSInteger b){
            NSLog(@"sum is %d", a + b);//没有引用任何外部变量
            
        };
        globalBlock(1,2);
        void (^globalBlock1) (NSInteger,NSInteger) = ^(NSInteger a, NSInteger b){
            NSLog(@"sum is %d", a + b + globalVar);//这里引用到了全局变量
            globalVar ++;
        };
        globalBlock1(1,2);
        

        
#pragma __NSMallocBlock__ && __NSStackBlock__
        /**
         
         NSStackBlock:使用retain,release操作无效；栈区block会在方法返回后将block空间回收； 使用copy将栈区block复制到堆区，可以长久保留block的空间，以供后面的程序使用；对已经在heap的block执行copy并不会生成新的block只是引用计数增加；
         
         NSMallocBlock:支持retian,release，虽然block的引用计数始终为1，但内存中还是会对引用进行管理，使用retain引用+1， release引用-1； 对于NSMallocBlock使用copy之后不会产生新的block，只是增加了一次引用，类似于使用retian;
         下面的理解更准确一些：http://www.solstice.com/blog/blocks-and-memory-management-stack-vs-heap
         Remember: If you use retain rather than copy with a block, it might work if the block is already in the heap. But, if your block is in the stack (and they are by default), you can not retain it.
         The block will be gone once it’s out of scope no matter how many retains do you have. In order to have your block retained pass its scope you should always use copy. Using copy more than once for the same object doesn’t create multiple copies of it - it only increases the retain count of that object in the heap.
         
         */
        
        //当blcok引用到外部变量的时或者通过alloc的对象时 此时block对象类型要区分是否为ARC
        // MRC下  __NSStackBlock__  这种模式下对其retain 或者release都无效 因为栈区内存管理跟retaicount没有关系
        // ARC下  __NSMallocBlock__ 所以在ARC下系统会自动把block copy到堆区
        NSInteger outsideVar = 10;
        void (^mallocBlock) (NSInteger,NSInteger) = ^(NSInteger a, NSInteger b){
            NSLog(@"sum is %d", a + b + outsideVar);
            
        };
        mallocBlock(1,2);
        //    id temp1 = [mallocBlock retain];//MRC下retain之后依然在栈区 属于__NSStackBlock__ 所以retain并不能起到期望的作用
        //    id temp2 = [mallocBlock copy];//如果在MRC下 执行这个操作后blcok类型就会变为 __NSMallocBlock__内存区域在堆区
        
        
        NSArray* a = [[NSArray alloc] init];;
        void (^mallocBlock2) (NSArray*) = ^(NSArray* arg){
            if (a.count == arg.count)
            {
                NSLog(@"%@",a);
            }
        };
        mallocBlock2(a);
        
        void (^mallocBlock3) (NSInteger,NSInteger) = ^(NSInteger a, NSInteger b){
//            _number = a + b;
            self.number = a + b;
            [self.myArray addObject:@"1234"];//着红情况下不会出现循环引用 因为 mallocBlock3属于一个局部变量 我认为在arc下它是一个缺省了__strong 的局部变量 在viewdidload执行完后会释放该block 所以不会出现循环引用因为没有形成引用链
            
        };
        mallocBlock3(1,2);

        
        
        
        [self combineString:@"hello" withString:@"world"];
        //    [self doSomethingWithBlock:^(id result) {
        //        NSLog(@"%@",result);
        //    }];
        NSLog(@"222");
        
    }
    
    /************ block导致的循环引用问题  ************/
    
    {
        __weak typeof (self) weakSelf = self;
        self.mBlcok = ^(id obj){
            //下面如果使用self替代weakSelf会导致循环引用 内存泄漏
            [weakSelf combineString:@"hello" withString:@"block"];
            //即便是不是直接引用self 引用其所持有的变量也会引起循环引用 因为block为了安全起见会对引用的变量进行强持有 防止block在执行时所引用的变量被提前释放掉 我理解的是block不会去单独的强持有某个实例的变量 这也不符合内存管理的原则 属于越权引用所以它只能持有该对象 因为该对象不释放其变量就是安全的
            [weakSelf.myArray removeAllObjects];
        };
        
        //以下block体中如果用self也会造成循环引用 因为self → peraon → block → self
        self.person = [[Person alloc] init];
        self.person.speakBlock = ^(NSString* contents){
            //假设person实例的block是某个异步操作 比如网络请求的回调中去执行 那么可能self已经被销毁 所以强持有一下weakself 等block执行完后 再释放 __strong 在block释放后会自动释放weakself也就是释放了self 不会造成内存泄漏 下面的log可以印证
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //            [self logContent:contents];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //如果使用weakSelf的话 如果self被5秒之内pop出去的话 weakself=nil 不会输出log
                //                [weakSelf logContent:@"五秒后我被执行啦"];
                
                [strongSelf logContent:@"五秒后我被执行啦"];
                /*
                 2016-10-01 18:25:16.761 BlockMemeorySample[18916:1131666] the content is 五秒后我被执行啦
                 2016-10-01 18:25:16.761 BlockMemeorySample[18916:1131666] ViewController is dealloced
                 2016-10-01 18:25:16.762 BlockMemeorySample[18916:1131666] Person is dealloced
                 
                 */
            });
        };
        self.person.speakBlock(@"person speak");
        
        
        
    }
    
}
-(void)backToRoot
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)logContent:(NSString*)content
{
    NSLog(@"the content is %@",content);
}

-(NSString*)combineString:(NSString* )a  withString:(NSString* )b
{
    return [a stringByAppendingString:b];
}

//block作为参数传递的时候是不会被copy的
-(void)doSomethingWithBlock:(void(^)(id result)) block
{
    block(@"111");
}

-(void)dealloc
{
    NSLog(@"%@ is dealloced",NSStringFromClass([self class]));
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
