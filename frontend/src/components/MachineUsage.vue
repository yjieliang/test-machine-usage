<template>
  <div
    style="height: 100%;"
    v-bkloading="{ isLoading, color: 'rgba(0,0,0,0)' }"
  >
    <bk-table
      class="machine-usage-table"
      v-show="!isLoading"
      :data="data"
      @expand-change="handleExpand"
    >
      <bk-table-column
        type="expand"
        width="30"
      >
        <template slot-scope="props">
          <bk-table
            @sort-change="(prop) => handleSort(props.row, prop)"
            :data="props.row.children"
            :outer-border="false"
            v-bkloading="{ isLoading: props.row.childLoading, color: 'rgba(0,0,0,0)' }"
            :header-cell-style="{ background: '#fff', borderRight: 'none' }"
          >
            <bk-table-column
              prop="jobName"
              label="Job名称"
            ></bk-table-column>
            <bk-table-column
              sortable="custom"
              prop="pipelineName"
              label="所属流水线"
            >
              <template v-slot="props">
                <a
                  target="_blank"
                  :href="`${CI_PREFIX}/pipeline/${projectCode}/${props.row.pipelineId}/history`"
                >{{ props.row.pipelineName }}</a>
              </template>
            </bk-table-column>
            <bk-table-column
              sortable="custom"
              prop="lastBuildTime"
              label="最近执行时间"
            ></bk-table-column>
          </bk-table>
        </template>
      </bk-table-column>
      <bk-table-column
        prop="displayName"
        label="别名"
      >
        <template v-slot="props">
          <a
            href="javascrip:;"
            @click="goNodeDetail(props.row)"
          >{{ props.row.displayName }}</a>
        </template>
      </bk-table-column>
      <bk-table-column
        prop="ip"
        label="内网IP"
      ></bk-table-column>
      <bk-table-column
        prop="osName"
        label="操作系统"
      ></bk-table-column>
      <bk-table-column
        prop="createdUser"
        label="来源/导入人"
      ></bk-table-column>
      <bk-table-column
        prop="nodeStatus"
        label="状态"
      >
        <template slot-scope="props">
          <div
            class="table-node-item node-item-status"
            v-if="props.row.nodeStatus === 'BUILDING_IMAGE'"
          >
            <span class="node-status-icon normal-stutus-icon"></span>
            <span class="node-status">正常</span>
          </div>
          <div class="table-node-item node-item-status">
            <!-- 状态icon -->
            <span
              class="node-status-icon normal-stutus-icon"
              v-if="successStatus.includes(props.row.nodeStatus)"
            ></span>
            <span
              class="node-status-icon abnormal-stutus-icon"
              v-else-if="failStatus.includes(props.row.nodeStatus)"
            >
            </span>
            <div
              class="bk-spin-loading bk-spin-loading-mini bk-spin-loading-primary"
              v-bkloading="{ isLoading: true, size:'mini', color: 'rgba(0,0,0,0)', theme: 'primary', mode: 'spin' }"
              v-else-if="runningStatus.includes(props.row.nodeStatus)"
            >
            </div>
            <!-- 状态值 -->
            <span
              class="install-agent"
              v-if="props.row.nodeStatus === 'RUNNING'"
              @click="installAgent(props.row)"
            >
              {{ $t('environment.nodeStatusMap')[props.row.nodeStatus] }}
            </span>
            <span
              class="node-status"
              v-else
            >{{ nodeStatusMap[props.row.nodeStatus] }}</span>
          </div>
        </template>
      </bk-table-column>
      <bk-table-column
        prop="pipelineRefCount"
        label="Job占用数量"
      ></bk-table-column>
      <bk-table-column
        prop="lastBuildTime"
        label="最近执行时间"
      ></bk-table-column>
    </bk-table>
  </div>
</template>
<script>
const CI_PREFIX = "https://devops.woa.com/console"
const API_PREFIX =
    "//devops.apigw.o.woa.com/prod/v3/apigw-user/environment/projects"

export default {
    props: {
        bkExtData: Object
    },
    data() {
        return {
            size: "small",
            isLoading: true,
            CI_PREFIX,
            data: [],
            runningStatus: [
                "CREATING",
                "STARTING",
                "STOPPING",
                "RESTARTING",
                "DELETING",
                "BUILDING_IMAGE"
            ],
            successStatus: ["NORMAL", "BUILD_IMAGE_SUCCESS"],
            failStatus: [
                "ABNORMAL",
                "DELETED",
                "LOST",
                "BUILD_IMAGE_FAILED",
                "UNKNOWN",
                "RUNNING"
            ],
            expandedIds: {}
        }
    },
    computed: {
        // sortOrders () {
        //   return [ 'ASC', 'DESC', null]
        // },
        nodeStatusMap() {
            return {
                NORMAL: "正常",
                ABNORMAL: "异常",
                DELETED: "已删除",
                LOST: "失联",
                CREATING: "正在创建中",
                RUNNING: "安装Agent",
                STARTING: "正在开机中",
                STOPPING: "正在关机中",
                STOPPED: "已关机",
                RESTARTING: "正在重启中",
                DELETING: "正在销毁中",
                BUILDING_IMAGE: "正在制作镜像中",
                BUILD_IMAGE_SUCCESS: "制作镜像成功",
                BUILD_IMAGE_FAILED: "制作镜像失败",
                UNKNOWN: "未知"
            }
        },
        projectCode() {
            return this.bkExtData.projectId
        }
    },
    mounted() {
        this.fetchPipelineExecuteDetail(this.projectCode)
    },
    watch: {
        bkExtData: {
            handler: function(bkExtData) {
                console.log("change bkExtData,", bkExtData)
                this.fetchPipelineExecuteDetail(bkExtData.projectId)
            },
            deep: true
        }
    },
    methods: {
        goNodeDetail(row) {
            const url = `/console/environment/${this.projectCode}/nodeDetail/${row.nodeHashId}`
            window.TCI.$goToPage({
                url
            })
        },
        async asyncFetch(url) {
            const res = await fetch(url, {
                credentials: "include",
                headers: {
                    Accept: "application/json"
                }
            })

            return res.json()
        },
        async fetchPipelineExecuteDetail(projectCode) {
            try {
                const result = await this.asyncFetch(
                    `${API_PREFIX}/${projectCode}/nodes/extListNodes`
                )

                this.data = result.data.map((node, index) => {
                    node.children = []
                    node.childLoading = false
                    node.sortBy = ""
                    node.sortDirection = ""
                    return node
                })
            } catch (e) {
                console.error(e)
                this.$bkMessage({
                    message: e.message || "接口调用失败",
                    theme: "error"
                })
            } finally {
                this.isLoading = false
            }
        },
        handleSort(row, { column, order, prop }) {
            // ascending 表示升序，descending 表示降序
            row.sortBy = prop
            switch (order) {
                case "ascending":
                    row.sortDirection = "ASC"
                    break
                case "descending":
                    row.sortDirection = "DESC"
                    break
                default:
                    row.sortBy = ""
                    row.sortDirection = ""
            }
            this.fetchNodeDetailLists(row)
        },

        async fetchNodeDetailLists(row) {
            row.childLoading = true
            try {
                const sortQuery = row.sortBy
                    ? `?sortBy=${row.sortBy}&sortDirection=${row.sortDirection}`
                    : ""
                const nodeDetailLists = await this.asyncFetch(
                    `${API_PREFIX}/${this.projectCode}/nodes/${row.nodeHashId}/listPipelineRef${sortQuery}`
                )
                this.expandedIds[row.nodeHashId] = true
                row.children = nodeDetailLists.data
            } catch (e) {
                console.error(e)
                this.expandedIds[row.nodeHashId] = false
            } finally {
                row.childLoading = false
            }
        },
        async handleExpand(row, expandedRows) {
            if (this.expandedIds[row.nodeHashId]) return
            this.expandedIds[row.nodeHashId] = true
            this.fetchNodeDetailLists(row)
        }
    }
}
</script>

<style lang="css">
  .machine-usage-table a{
     text-decoration: none;
     cursor: pointer;
     
     color: #3c96ff;
     
  }

  .node-status-icon {
        display: inline-block;
        margin-left: 2px;
        width: 10px;
        height: 10px;
        border: 2px solid #30D878;
        border-radius: 50%;
        -webkit-border-radius: 50%;
    }

    .abnormal-stutus-icon {
        border-color: #ff5656;
    }
  
</style>