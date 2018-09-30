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



搞清楚choerodon的大架构：
1. 总体架构
2. 消息机制
3. 数据库相关
4. 测试相关

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









    <where>
            <if test="dto!=null and dto.issueId != null">
                issue_id in
                <foreach item="dto" index="index" collection="dtos"
                         open="(" separator="," close=")">
                    #{dto.issueId}
                </foreach>
            </if>
            <if test="dto!=null and dto.cycleId != null">
                AND cycle_id in
                <foreach item="dto" index="index" collection="dtos"
                         open="(" separator="," close=")">
                    #{dto.cycleId}
                </foreach>
            </if>
            <if test="dto!=null and dto.executeId != null">
                AND execute_id in
                <foreach item="dto" index="index" collection="dtos"
                         open="(" separator="," close=")">
                    #{dto.executeId}
                </foreach>
            </if>
            <if test="dto!=null and dto.executionStatus != null">
                AND execution_status in
                <foreach item="dto" index="index" collection="dtos"
                         open="(" separator="," close=")">
                    #{dto.executionStatus}
                </foreach>
            </if>
            <if test="dto!=null and dto.comment != null">
                AND comment like
                <foreach item="dto" index="index" collection="dtos"
                         open="(" separator="," close=")">
                    CONCAT(CONCAT('%', #{dto.comment}), '%')
                </foreach>
            </if>
            <if test="dto!=null and dto.assignedTo != null">
                AND assigned_to in
                <foreach item="dto" index="index" collection="dtos"
                         open="(" separator="," close=")">
                    #{dto.assignedTo}
                </foreach>
            </if>
            <if test="dto!=null and dto.lastUpdatedBy != null">
                AND last_updated_by in
                <foreach item="dto" index="index" collection="dtos"
                         open="(" separator="," close=")">
                    #{dto.lastUpdatedBy}
                </foreach>
            </if>
            <!--<if test="dto!=null and dto.lastUpdateDate != null">-->
                <!--AND last_update_date <![CDATA[>=]]> #{dto.lastUpdateDate}-->
                <!--last_update_date in-->
                <!--<foreach item="dto" index="index" collection="dtos"-->
                         <!--open="(" separator="," close=")">-->
                    <!--#{dto.executeId}-->
                <!--</foreach>-->
            <!--</if>-->
        </where>




                <where>
            <foreach item="dto" index="index" collection="dtos"
                     open="(" separator="," close=")">
                <if test="dto!=null and dto.issueId != null">
                    AND issue_id = #{dto.issueId}
                </if>
                <if test="dto!=null and dto.cycleId != null">
                    AND cycle_id = #{dto.cycleId}
                </if>
                <if test="dto!=null and dto.executeId != null">
                    AND execute_id = #{dto.executeId}
                </if>
                <if test="dto!=null and dto.executionStatus != null">
                    AND execution_status = #{dto.executionStatus}
                </if>
                <if test="dto!=null and dto.comment != null">
                    AND comment like CONCAT(CONCAT('%', #{dto.comment}), '%')
                </if>
                <if test="dto!=null and dto.assignedTo != null">
                    AND assigned_to = #{dto.assignedTo}
                </if>
                <if test="dto!=null and dto.lastUpdatedBy != null">
                    AND last_updated_by = #{dto.lastUpdatedBy}
                </if>
                <if test="dto!=null and dto.lastUpdateDate != null">
                    AND last_update_date <![CDATA[>=]]> #{dto.lastUpdateDate}
                </if>
            </foreach>
        </where>


            <select id="queryWithAttachAndDefect_oracle" resultMap="BaseResultMap">
        SELECT
        cycle.execute_id,
        cycle.cycle_id,
        cycle.issue_id,
        cycle.rank,
        cycle.object_version_number,
        cycle.execution_status,
        cycle.assigned_to,
        cycle.description,
        attach.url,
        attach.attachment_name,
        attach.id,
        cycle.last_update_date,
        cycle.last_updated_by,
        defect.defect_type,
        defect.id defece_id,
        defect.defect_link_id,
        defect.issue_id defect_issue_id
        FROM
        (
        SELECT
        *
        FROM
        (
        SELECT
        tt.*, ROWNUM AS rowno
        FROM
        (
        SELECT
        *
        FROM
        test_cycle_case
        <where>
            <if test="dto!=null and dto.issueId != null">
                AND issue_id = #{dto.issueId}
            </if>
            <if test="dto!=null and dto.cycleId != null">
                AND cycle_id = #{dto.cycleId}
            </if>
            <if test="dto!=null and dto.executeId != null">
                AND execute_id = #{dto.executeId}
            </if>
            <if test="dto!=null and dto.executionStatus != null">
                AND execution_status = #{dto.executionStatus}
            </if>
            <if test="dto!=null and dto.comment != null">
                AND description like CONCAT(CONCAT('%', #{dto.comment}), '%')
            </if>
            <if test="dto!=null and dto.assignedTo != null">
                AND assigned_to = #{dto.assignedTo}
            </if>
            <if test="dto!=null and dto.lastUpdatedBy != null">
                AND last_updated_by = #{dto.lastUpdatedBy}
            </if>
            <if test="dto!=null and dto.lastUpdateDate != null">
                AND last_update_date <![CDATA[>=]]> #{dto.lastUpdateDate}
            </if>
        </where>
        ORDER BY
        RANK
        ) tt
        <if test="pageSize !=0">
        WHERE
            <![CDATA[ROWNUM <= #{pageSize}]]>
        </if>
        ) table_alias
        <if test="pageSize !=0">
        WHERE
            <![CDATA[ table_alias.rowno >= #{page}]]>
        </if>
        ) cycle
        LEFT JOIN test_cycle_case_attach_rel attach ON cycle.execute_id = attach.attachment_link_id
        AND attach.attachment_type = 'CYCLE_CASE'
        LEFT JOIN test_cycle_case_defect_rel defect ON cycle.execute_id = defect.defect_link_id
        AND defect.defect_type = 'CYCLE_CASE'
    </select>

    List<TestIssueFolderDTO> folderDTOS = testIssueFolderService.queryByParameterWithPageUnderProject(projectId, new PageRequest(0, 99999, new Sort(Sort.Direction.DESC, "versionId")));

    中断异常