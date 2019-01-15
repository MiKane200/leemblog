1. DDD（领域驱动模型）                         √
2. 文档（后端开发）                            √
3. 重过自己写过地代码                          √
4. 表结构+项目流程（包括测试平台）+项目编码      √
5. 单元测试 spock（Mock）                      √
6. java8                                      √
7. 通用mapper，update批量更新，mybatis         √
8. groovy语法                                 √
9. 操作类型转换list，数组                      √
10. @permission权限
11. 常用快捷键：
    1. Ctrl q 查看方法参数
    2. Ctrl alt 左右键 对于当前操作前进后退
12. sql优化

规范：
1. 金额、数量 等精度严格浮点类型采用 BigDecimal，注意：BigDecimal 在计算、比较方面的特殊性
2. 所有的主键字段都需要用@Id标注，对于自增张、序列（SEQUENCE）类型的主键，需要添加注解@GeneratedValue。
序列命名规范：表名_S。例如：表SYS_USER对应的序列为 SYS_USER_S
3. 非数据库字段需要用@Transient标注 javax.persistence.Transient
4. 其中如果层级为组织层或项目层，则接口的mapping 中必须包含organization_id 或 project_id 作为变量。
否则gateway-helper校验时不会识别该权限。
5. 小数类型为 decimal，禁止使用 float 和 double。

本周完成的工作：
1. 完成数据表test_cycle_case_defect_rel字段project的增加和后端关于修改表中project字段值的方法。
2. 完成对报表（从缺陷到要求的重构）。
3. 完成test_issue_folder表的增加，完成其对应的CRUD功能，其中完成查找功能时，要求要将folder放置到项目下的version下，组成树的结构返回给前端。


测试使用流程：
1. 创建自己的测试用例
2. 创建测试步骤
3. 测试执行
4. 完成测试

开发流程：
1. 先去敏捷管理中创建问题
2. 开发流水线创建问题分支
3. 将分支fetch下来，进行开发
4. 开发完成，然后在自己分支上对远程的master分支进行rebase，再将分支push上去进行跑CI
5. CI出错的话，重复4操作。
6. CI正常跑过，去合并然后删除自己分支。
7. 部署应用。
8. 部署完成后，查看是否正常工作。


个人遇到的问题及其解决：
1. Permission
2. 领域驱动模型
    1. 通过讲解听懂部分但还是没全掌握
    2. 通过实际操作去发现自己的问题
    3. 主动去询问某个点它为什么会这样
    4. 比如controller调用service时，我一直以为domain和app中的service都能调用，
    但实际是面对controller提供服务的就只有app中的service。而domain中的service则是通过app来调用的。
    5. 还有一个初期我认为是我理解难点的就是entity，关于某个数据表自身的相关操作就在entity中实现简单地增删查改，
    而service中写的逻辑则是用于描述多个复杂关联操作的时候。domain去调用的是entity中的方法。entity又会是调用responsity中的方法。过~~
    6. 当时写的时候晕头转向的，但自己静下心来仔细想想，慢慢去分析各层的调用关系，理解它们参数之间的作用效果。
    7. 下来加深对领域驱动模型的理解。
    8. 再次过一遍后端文档不一样的收获：
3. 通用mapper用不了，比如之前用的Example 辅助查询用不了。解决方法是回归以前的mybatis用法在xml中写sql语句。
```java
Example example = Example.builder(Customer.class)
                .select("lastName")
                .where(Sqls.custom().andEqualTo("firstName", firstName))
                .build();
List<Customer> customers = customerMapper.selectByExample(example);
```
4. 完成第一个任务时，修改groovy脚本导致数据库要发生变化而自己连接的是远程的数据库，
（是因为没有去执行groovy脚本），所以要先push进行ci集成，部署之后，改变数据库结构，才能使用swagger进行测试。
5. entity多例注解@property（使用spring来得到对象实例，不能new--脱离了spring的管理），导致spring无法管理此对象报出空指针。
这个时候使用工厂方法去调用spring工厂生成实例Bean。如：ApplicationContextHelper.getSpringFactory().getBean(TestCaseStepE.class);


结对编程：
1. 写出的代码要有人来给你review，看出那些地方有错，特别是对于新手，虽然看着前辈写的代码，能写出来。但其中很多自己不懂地，
而去运用的时候，可能会因为自己的不理解导致各种各样地bug，这时候就体现出结对编程的好处了，有有丰富经验的人来给你review能
快速指出你的不足，同时能给你在某些点上的难点和编码写法上给出建议。



周一：
向缺陷表中添加projectId字段（为了区分不同projectId下的缺陷），之后编写功能将表中的每一行都加上相应的projectId数据。

周二：
从缺陷到issue报表的重构。

1. 拿到projectId并根据它到test_cycle_case_defect_rel表中去找project下对应的issueId和defectId把他们映射到取出来的map上
2. 然后将前端发来的筛选条件和查出来的issueId发送给敏捷服务那边
3. 让他们根据条件去筛选之后返回给我们符合条件的issueId
4. 将这些issueId暂存到一个类的Long[]数组中（之后分页会用到，避免去回表重查）
5. 将issueId根据前端的pageRequest进行分页得到需要展现给前端的issueId数组
6. 再去用这个数组回查map数据，调用服务取得远程issue数据与自己数据库数据拼接，并返回。（服务端内存中存储了数据，用户量少的时候不会有什么影响，当用户量一多，内存可能不足导致崩掉··）

1. 拿到projectId和筛选条件送给敏捷，他们返回筛选后的issueIds
2. 根据返回的issueIds进行分页
3. 用分页后的ids去调用远程服务得到对应的issue数据
4. 从issueIds中过滤出caseId，stepId然后在test_cycle_case_step，test_cycle_case，test_cycle等表中进行查找，得到数据
5. 和1中的数据进行拼接，并将其和issueIds返回给前端。
6. 当第二次去访问的时候，前端它传需要的ids到后端，然后根据这些数据还是一样分别从远程和本地拿到数据拼接返给前端。


周四：
根据projectId查找数据库将项目下的folder拿出来，然后调用远程服务拿到在项目下的version，之后将两组数据进行整合，组成树结构返给前端。

周五：
完成issue_folder_rel表增添，完成CRUD。R：

周一：
. 批量添加rel关系
. queryOne
. 根据folderId查询Issue

显示所有已完成的（筛选条件）

日志异常规范：
runex：代码解决
业务异常：手动跑出，commonexception继承

{
    "epicId": 0,
    "parentIssueId": 0,
    "priorityCode": "medium",
    "projectId": 144,
    "sprintId": 0,
    "summary": "sdd",
    "typeCode": "issue_test",
    "versionIssueRelDTOList": [
        {
                "relationType": "fix",
                "versionId":167
        }
    ]
}

task：
folderId,type(剪切和复制),issueId数组
（一个接口，实现剪切move和复制copy）

参数
/agile/v1/projects/144/issues/9451/clone_issue POST

移动issue参数：
folderId:1,
issues:
[{
"issueId":9568,
"objectVersionNumber":1
},{
"issueId":9569,
"objectVersionNumber":1
}]

移动文件夹参数：
{
  "folderId": 19,
  "objectVersionNumber": 6,
  "versionId": 168
}

明天任务：
1. 先去调试一哈update更新的时候需不需要主键=> 需要就自己写mapperxml。
2. 调用敏捷方法时候，fegin重写的时候里面的参数类，需不需要写一个出来。


https://api.choerodon.com.cn/manager/swagger-ui.html#!/issue-controller/batchIssueToVersionUsing 
POST

任务：
1. 写一个批量根据issueId查询versionNumber的方法（改进算法）


bug参数:
1. /v1/projects/{project_id}/cycle PUT


{
"assignedTo":1663,
"cycleId":927,
"lastUpdatedBy":8956
}
1. cycle_name 查出来，cycleCaseDTO中添加name属性
2. 手动分页
3. 取出来的cycleId对应


$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com


    @Override
    public Page<TestCycleCaseDTO> queryByCycleAndFolder(TestCycleCaseDTO dto, PageRequest pageRequest, Long projectId) {
        //所有的阶段的所有case
        List<TestCycleCaseDTO> allDTOS = new ArrayList<>();
        //elements总数
        Long total = 0L;

        TestCycleDTO queryTestCycleDTO = new TestCycleDTO();
        queryTestCycleDTO.setCycleId(dto.getCycleId());
        //找到所有的子阶段
        List<TestCycleE> testCycleES = iTestCycleService.queryChildCycle(ConvertHelper.convert(queryTestCycleDTO, TestCycleE.class));
        //装配值进DTO中
        List<TestCycleCaseDTO> testCycleCaseDTOS = new ArrayList<>();
        testCycleCaseDTOS.add(dto);
        testCycleES.forEach(v -> {
                    TestCycleCaseDTO tempDTO = new TestCycleCaseDTO();
                    tempDTO.setAssignedTo(dto.getAssignedTo());
                    tempDTO.setLastUpdatedBy(dto.getLastUpdatedBy());
                    tempDTO.setCycleId(v.getCycleId());
                    tempDTO.setCycleName(v.getCycleName());
                    testCycleCaseDTOS.add(tempDTO);
                }
        );

        //分页数据
        int lowPage = pageRequest.getPage() * pageRequest.getSize();
        int highPage = lowPage + pageRequest.getSize();

        //查找所有的阶段的所有case，装配进CaseDTOS中
        for (TestCycleCaseDTO testCycleCaseDTO : testCycleCaseDTOS) {
            if (highPage > lowPage) {
                //取出剩余size的数据
                pageRequest.setSize(highPage-lowPage);
                Page<TestCycleCaseE> serviceEPage = iTestCycleCaseService.query(ConvertHelper.convert(testCycleCaseDTO, TestCycleCaseE.class), pageRequest);
                //一个阶段下的所有case
                Page<TestCycleCaseDTO> dtos = ConvertPageHelper.convertPage(serviceEPage, TestCycleCaseDTO.class);
                total += dtos.getTotalElements();
                allDTOS.addAll(dtos.getContent());
                //变更顶点
                highPage -= dtos.getTotalElements();
            }
        }

        //分页操作
        PageInfo info = new PageInfo(pageRequest.getPage(), pageRequest.getSize());
        Page<TestCycleCaseDTO> pageDTOS = new Page<>(allDTOS, info, total);
//        CustomPage<TestCycleCaseDTO> customPage = new CustomPage<>(allDTOS,allDTOS.stream().map(TestCycleCaseDTO::getCycleId).toArray(Long[]::new));
//        customPage.setTotalElements(total);

        populateCycleCaseWithDefect(pageDTOS, projectId);

        populateUsers(pageDTOS);

        return pageDTOS;
    }

    中断异常

        
搞清楚choerodon的大架构：
1. 总体架构
2. 消息机制
3. 数据库相关
4. 测试相关

接下来看的额外要点：
1. IO框架及其里面要使用的一些常用的方法






1. 在当前分支开发完了之后，去主分支git pull --rebase
2. 切回当前开发分支，push




参与测试管理微服务功能模块的设计、开发与变更
经历Choerodon 0.7.0-0.11.0的版本迭代，熟悉了微服务的设计、开发、发布、管理流程
Developed new filing and organizational practices, saving the company $3,000 per year in contracted labor expenses
Maintain utmost discretion when dealing with sensitive topics
Manage travel and expense reports for department team members 


    @Permission(level = ResourceLevel.PROJECT, roles = {InitRoleCode.PROJECT_MEMBER, InitRoleCode.PROJECT_OWNER})
    @ApiOperation("删除文件夹下的issue")
    @PutMapping("/delete")
    public ResponseEntity delete(@PathVariable(name = "project_id") Long projectId,
                                 @RequestBody List<Long> issuesId) {
        testIssueFolderRelService.delete(projectId,issuesId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }


            List<IssueInfosDTO> issueInfosDTOS = new ArrayList<>();
            for (TestIssueFolderRelDTO relTestIssueFolderRelDTO : resTestIssueFolderRelDTOS) {
                IssueInfosDTO issueInfosDTO = new IssueInfosDTO();
                issueInfosDTO.setIssueId(relTestIssueFolderRelDTO.getIssueId());
                issueInfosDTOS.add(issueInfosDTO);
            }


14855
1. prorityCode(为priority-null)
2. 删除issue时，过多会造成错误


ssh -oPort=6000 vivianus@ettwz.japaneast.cloudapp.azure.com

-e "MINIO_ACCESS_KEY=ceshiguanli" \
  -e "MINIO_SECRET_KEY=ceshiguanli" \
  -v G:\data:/data \
  -v G:\minio\config:/root/.minio \

  docker run -d -p 9000:9000 --name=minio -e "MINIO_ACCESS_KEY=ceshiguanli" -e "MINIO_SECRET_KEY=ceshiguanli" -v G:\data:/data -v G:\minio\config:/root/.minio registry.saas.hand-china.com/tools/minio:latest server /minioData

  docker run -d -p 9000:9000 --name minio -e "MINIO_ACCESS_KEY=ceshiguanli" -e "MINIO_SECRET_KEY=ceshiguanli" -v G:\data:/data -v G:\minio\config:/root/.minio registry.saas.hand-china.com/tools/minio:latest server /data



  工作：
## 0.10.0
1. 缺陷表功能重构
2. 增添folder，folderRel
3. cycle功能
4. 初步接触spock测试
5. 迭代数据修复
6. 修改更新后文档

## 0.11.0
1. issue的Excel导出
2. 



test_env_command

id                  bigint(20)
value_id            bigint(20)
command_type        varchar(32) -- create/restart
ovn
cb
cd
lub
lud



test_env_command_value

id                  bigint(20)
value               text



test_app_instance

id                  bigint(20)
code                varchar(64)
app_id              bigint(20)
app_version_id      bigint(20)
project_version_id  bigint(20)
env_id              bigint(20)
command_id          bigint(20)
project_id          bigint(20)
pod_status   0 待处理 / 1 处理中 / 2 已完成 / 3 失败
log_id
ovn
cb
cd
lub
lud

索引：
1. app_id与env_id联合索引
2. code与env_id联合索引
3. log_id


test_app_instance_log

id
log

test_automation_history

id
framework
test_status  0 未执行 / 1 全部成功 / 2 部分成功
instance_id
project_id
cycle_id
result_id
ovn
cb
cd
lub
lud



test_automation_result


id
result

包含缺陷表的功能重构，
文件夹及其issue关联关系，
测试循环相关功能调整，
编写spock单测，
旧数据迭代修复，
测试用例的Excel导出，
版本升级的文档更新，
自动化测试部署。

{"deploy":"{\"isNotChange\":true,\"appId\":662,\"code\":\"test-mocha\",\"appVerisonId\":582,\"environmentId\":16,\"projectVersionId\":233,\"values\":\"# Default values for api-gateway.\\r\\n# This is a YAML-formatted file.\\r\\n# Declare variables to be passed into your templates.\\r\\n\\r\\nreplicaCount: 1\\r\\n\\r\\nimage:\\r\\n  repository: registry.saas.hand-china.com/operation-test-manager/test-mocha\\n  pullPolicy: Always\\r\\n\\r\\nframework: mocha\\r\\n\\r\\nenv:\\r\\n  open:\\r\\n    APIGATEWAY: http://api.staging.saas.hand-china.com\\r\\n    PROJECTID: 144\\r\\n    USERNAME: 16965\\r\\n    PASSWORD: Smartisan0000\\r\\n    RESULTGATEWAY: http://api.staging.saas.hand-china.com\\r\\n    RESULTPATH: mochawesome-report\\r\\n    RESULTNAME: mochawesome\\r\\n    SLOW: 250\\r\\n    TIMEOUT: 15000\\r\\n\\r\\njob:\\r\\n  activeDeadlineSeconds: 1200\\r\\n\\r\\nresources:\\r\\n  # We usually recommend not to specify default resources and to leave this as a conscious\\r\\n  # choice for the user. This also increases chances chart run on environments with little\\r\\n  # resources,such as Minikube. If you do want to specify resources,uncomment the following\\r\\n  # lines,adjust them as necessary,and remove the curly braces after 'resources:'.\\r\\n  limits:\\r\\n    # cpu: 100m\\r\\n    # memory: 2Gi\\r\\n  requests:\\r\\n    # cpu: 100m\\r\\n    # memory: 1Gi\\r\\n\\n\",\"type\":\"update\"}","projectId":144,"projectName":"测试管理开发项目","projectCode":"test-manager"}










第一张：
名称：西南石油大学
纳税人识别号：12510000452189430X
地址、电话：四川省成都市新都区新都大道8号028-8303235
开户行及账号：中国农业银行新都支行 22824101040014888
费用类型：电子产品
商品名：Intel/英特尔固态SSD硬盘 型号：760P 256G 单位：个 单价：450元，数量：3 金额：1350元 人民币

第二张：
公司名称:成都盛特石油装备模拟技术股份有限公司
统一社会信用代码:915101006909437423
地址:成都高新区肖家河中街46号
开户行及账号:中国工商银行股份有限公司成都高新技术产业开发区支行 4402233009100058448
费用类型：电子产品
商品名：金士顿DDR3内存条 型号：KVR16N11/8-SP ，单位：条 ，单价：399元， 数量：3 ，金额：1197元 人民币



收件地址：四川省成都市新都区新都大道8号
联系人，号码：朱倍仪:15283399363

用户瞎几把输入比如：XVVVVVIIIIIIII的情况考虑！

1. 字码输入 M D C L X V I  将写入的字符串获取为char[]
2. 设计一个类S，使用linkHashMap A，用于装载原罗马字符（如key:M=>value:1000,key:D=>value100），设置一个HashMap B用于对罗马数字出现频率计数，设置一个熟悉size表示打印出来的字符串的 规格大小
3. 处理char数组，从第一位开始读取，将读取到的值作为key，从A中获取值
    1. 如果读取的key不包含在A中，则提示错误，打印E，退出程序
    2. 如果读取的key有值，是M在B中M key处加1，是D在B···加1,···等
    3. 有值的话，将该处之前的罗马字符删除掉，比如 V 则，删除掉MDCLX
4. 使用二维数组arr[][],遍历S的B中标志位
    1. 0不输出
    2. >0判断具体数字输出 设置值进去



    Error:Groovyc: While compiling tests of zongweiliwork: Could not instantiate global transform class org.spockframework.compiler.SpockTransform specified at jar:file:/C:/Users/minute5/.m2/repository/org/spockframework/spock-core/1.2-groovy-2.5/spock-core-1.2-groovy-2.5.jar!/META-INF/services/org.codehaus.groovy.transform.ASTTransformation  because of exception java.lang.NullPointerException


    ICVXIM