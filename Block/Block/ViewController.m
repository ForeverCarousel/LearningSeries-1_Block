//
//  ViewController.m
//  BlockMemeorySample
//
//  Created by Carouesl on 16/9/27.
//  Copyright © 2016年 Youku Tudou Inc. All rights reserved.
//

/**
                                iOS_Develop_Samples_Series-1
 
 这个示例主要介绍了block的三种类型 以及这三种类型的内存管理 和MRC ARC下的区别  主要是为了防止产生内存泄露和悬空指针问题  具体block的实现可以用clang -rewrite-objc 编译一个类的.m文件看中间代码的实现 网上也有N多解析的例子
 
 */
#import "ViewController.h"
#import "Person.h"

typedef void(^myBlock)(id obj);

@interface ViewController ()

@property (nonatomic,   copy) myBlock mBlcok;
@property (nonatomic, strong) NSMutableArray* myArray;
@property (nonatomic, strong) Person* person;
@property (nonatomic, assign) NSInteger number;
@end



@implementation ViewController



__weak id observerObject = nil; //全局变量 位于全局区或者叫静态去 这里定义这个是用来观察viewdidload中定义的block在viewdidload执行完毕之后的状态

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
    
    
    /**
                                基础的内存分区问题 (详细见工程内的内存分区图)
     
    int stackVar = 1;               //1位于常量区  stackVar位于stack去
     
    NSString* stackStr = @"123";    //@"123"位于常量区   stackStr在栈区
     
    NSString* heapStr = [[NSString alloc] init]; //heapStr变量是在堆区(这里之前理解错了 我以为变量本身在栈区 指向的空间在堆区)  指向的内存在堆区
        函数的参数实际上是一种局部变量都是保存在栈区
     
     总结：
一、 栈区内存 （运行时分配）
     
     1.局部变量的存储空间基本都是栈区,局部变量在函数,循环,分支中定义
     
     2.在栈区的存储空间由高向低分配,从低向高存储.
     
     3.栈区内存由系统负责分配和回收,程序员开发者没有管理权限.
     
     4.当函数,循环,分支执行结束后,局部变量的生命周期就结束了.之后不能再进行使用,由系统销毁
     
     5.栈底,栈顶:栈底是栈区内存的起始位置,先定义的变量所占用的内存,从栈底开始分配,后定义的变量所占用的内存,逐渐向栈顶分配.
     
     6.入栈,出栈:入栈,定义新的局部变量,分配存储空间.出栈,局部变量被销毁,存储空间被收回.
     
     7.栈的特点:先进后出,后进先出.例如:子弹夹添加子弹,打出子弹.
     
二、堆区内存 (运行时分配)
     
     1.由开发者负责分配和回收.
     
     2.忘记回收会造成泄漏.
     
     3.程序运行结束后,需要及时回收堆内存,但是如果不能及时回收堆内存程序运行期间可能会因为内存泄漏造成堆内存被全部使用,导致程序无法使用.

三、常量区内存 (编译时分配)
     
     1.常量存储在常量区,例如:常量数字,常量字符串,常量字符,
     
     2.常量区存储空间由系统分配和回收
     
     3.程序运行结束后,常量区的存储空间被回收
     
     4.常量区的数据只能读取,不能修改,修改的话会造成崩溃.
     
四、静态区内存 (编译时分配)
     
     1.全局变量,使用static修饰的局部变量,都存储在静态区.
     
     2.静态区的存储空间由系统分配和回收.
     
     3.程序运行结束后,静态区的存储空间被回收,静态变量的生命周期和程序一样长.
     
     4.静态变量只能初始化一次,在编译时进行初始化,运行时可以修改值
     
     5.静态变量如果没有设置初始值,默认为0.
     
五、代码区内存
     
     1.由系统分配和回收
     
     2.程序运行结束之后,由系统回收分配过的内存存储空间
     
    */
    
//*********************************************************************************
    
    
    /**
                        Block
一、 类型
     
     首先block分为以下三种类型：
     1. NSGlobalBlock：位于内存代码区 我理解的是和函数在一样的内存区？
     
     2. NSStackBlock： 位于内存栈区
     
     3. NSMallocBlock：位于内存堆区
     
     对于block，有两个内存管理方法：Block_copy, Block_release;Block_copy与copy等效， Block_release与release等效；
     
     不管是对block进行retian,copy,release,block的引用计数都不会增加，始终为1；
     */
 
/**
二、引用变量问题
     
     1.block可以引用外部变量但是不可以直接修改其值，但是可以修改全局变量  静态变量 静态全局变量
     2.用__block修饰的局部变量可以在block内部修改 其根本原因是如果有一个局部变量被__block修饰 并且被某一个block引用了之后 其指针指向的区域会被由stack区copy至heap区具体见下面的示例
     
 
    
    示例1：block访问外部变量
*/
    int varA = 10;
    NSLog(@"定义时的地址varA:  %p", &varA);// 局部变量在栈区
/*
    在定义block的时候，如果引用了外部变量,默认是把外部变量当做是常量编码到block当中，并且把外部变量copy到堆中，外部变量值为定义block时变量的数值
     
    如果后续再修改x的值，默认不会影响block内部的数值变化！
    
     在默认情况下，不允许block内部修改外部变量的数值！因为会破坏代码的可读性，不易于维护！
*/
    void(^myBlockA)() = ^ {
        
        NSLog(@"%d", varA);
        NSLog(@"被block引用时的地址varA: %p", &varA); // 堆中的地址
    };
/*
    输出是10,因为block copy了一份x到堆中
*/
    NSLog(@"引用后的地址varA:  %p", &varA);  // 栈区
    varA = 20;
    
    myBlockA();
    
/*
    示例2：在block中修改外部变量
    使用 __block，说明不在关心x数值的具体变化
*/
    __block int varB = 10;
    NSLog(@"定义时varB的地址: %p", &varB);                 // 栈区
    
/*
    定义block时，如果引用了外部使用__block的变量，在block定义之后, block外部的x和block内部的x指向了同一个值,内存地址相同
*/
    void (^myBlockB)() = ^ {
        varB = 80;
        NSLog(@"被block引用时varB的地址: %p", &varB);          // 堆区
    };
    NSLog(@"引用后varB的地址: %p", &varB);                 // 堆区 这里已经修改varB的内存位置
    
    myBlockB();
    NSLog(@"%d", varB);//打印x的值为8，且地址在堆区中
   
    
                    /************ block类型以及内存问题  ************/

#pragma __NSGlobalBlock__
{ //折叠
        
/*
 无论ARC或者MRC 当blcok没有引用到外部变量的时或者引用到的变量是全局变量 此时block对象类型是__NSGlobalBlock__
这种类型的block的内存区为代码区  retain copy release都无效 在MRC下__NSStackBlock__同理 当它所在的函数返回后 栈内存会被系统回收  即使某个block被添加到数组或其他集合中也不能持有 因为stack的内存和text区的内存并不是以引用计数来判断的  内存的释放归属于系统
*/
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
        //    id temp2 = [mallocBlock copy];//如果在MRC下 执行这个操作后block类型就会变为 __NSMallocBlock__内存区域在堆区
        
        
        NSArray* a = [[NSArray alloc] init];;
        void (^mallocBlock2) (NSArray*) = ^(NSArray* arg){
            if (a.count == arg.count)
            {
                NSLog(@"%@",a);
            }
        };
        mallocBlock2(a);
        
        void (^mallocBlock3) (NSInteger,NSInteger) = ^(NSInteger a, NSInteger b){
            self.number = a + b;
            [self.myArray addObject:@"1234"];//这种情况下不会出现循环引用 因为 mallocBlock3属于一个局部变量 我认为在arc下它是一个缺省了__strong 的局部变量 在viewdidload执行完后会释放该block 所以不会出现循环引用因为没有形成引用链
            
        };
        mallocBlock3(1,2);

        
        
        
        [self combineString:@"hello" withString:@"world"];
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
