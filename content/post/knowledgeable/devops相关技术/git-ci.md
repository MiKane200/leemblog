# 工作/学习总结

## gitlab-ci

### 简介
这是一个持续集成/持续交付的框架。通过为项目配置一个或多个 GitLab Runner，然后使用 .gitlab-ci.yml，就能够利用 GitLab CI/CD 来为项目引入持续集成/交付的功能。

### 执行的大体流程

#### Stage
每个 GitLab CI/CD 都必须包含至少一个 Stage。多个 Stage 是按照顺序执行的。如果其中任何一个 Stage 失败，则后续的 Stage 不会被执行，整个 CI 过程被认为失败。

1. build 被首先执行。如果发生错误，本次 CI 立刻失败；
2. test 在 build 成功执行完毕后执行。如果发生错误，本次 CI 立刻失败；
3. deploy 在 test 成功执行完毕后执行。如果发生错误，本次 CI 失败。

* 如果文件中没有定义 stages，那么则默认包含 build、test 和 deploy 三个 stage。
* Stage中不能有任何执行逻辑

### 具体配置

#### Job
1. Job通过是被关联一个Stage上的，当一个stage执行，关联它的所有job都被执行。
2. Job可以并行执行，可以利用多个 Runner 来加速 CI/CD 的流程。
3. 格式如下：`job_build_module_A: stage: build`
4. 如果一个 Job 没有显式地关联某个 Stage，则会被默认关联到 test Stage。
5. Job 包含了真正的执行逻辑，例如调用 mvn 或者 gcc 等命令。
```yaml
job_build_module_A:
  script:
    - cd module_A
    - mvn clean compile
```

##### 全局配置项
before_script 和 after_script 两个全局配置项。这两个配置项在所有 Job 的 script 执行前和执行后调用。比如：
```yaml
before_script:
  - export MAVEN_OPTS="-Xmx256m"

job_build_module_A:
  script:
    - cd module_A
    - mvn clean compile

...

job_build_module_Z:
  script:
    - cd module_Z
    - mvn clean compile
```

#### 公共数据
1. ob 的执行过程中往往会产生一些数据，默认情况下 GitLab Runner 会保存 Job 生成的这些数据，然后在下一个 Job 执行之前（甚至不局限于当次 CI/CD）将这些数据恢复。这样即便是不同的 Job 运行在不同的 Runner 上，它也能看到彼此生成的数据。
2. cache.key 有这个配置的目的是，比如上一次在dev分支跑出来的数据，在下一次切换到master分支引用的数据可能是dev的，这时候就需要使用key来指定这次引用数据为master分支。即所有的 Job 在恢复 cache 的时候，是根据当前的分支名称去选择对应的 cache。换句话说，前面例子中的两次 build 会选中不同的 cache，数据自然就隔离开了。
```yaml
cache:
  key: "$CI_COMMIT_REF_NAME-$CI_COMMIT_REF_NAME"
```