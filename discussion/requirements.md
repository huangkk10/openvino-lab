* 目前階段已完成
    * 在 windows 上 setup openvino 的環境
        * 使用 LENOVO Legion 7i (16", Gen 10)
    * 使用 benchmark 程式已經可以跑出 TTFT 的結果
    * 使用 NvmePassThroughApp.exe 執行出錯，看來需要使用支援 VMD Controller 的 platform

* 問題
    1. 是否一定需要  ARL-H platform
    2. 是否一定需要使用有支援 VMD Controller 的 platform
    3. 這次 POC SSDs 的目的是什麼?
        - 使用 benchmark 程式已經可以跑出 TTFT 的結果，看這個數據的目的是什麼?
        - 使用 NvmePassThroughApp.exe 的目的是什麼?
    4. 你在開發時，使用的 platform 型號是什麼? 是否建議我們也 setup 相同型號的 platform?



---
## Note

* DSM Hint

DSM Hint 是對「資料集（dataset）」的存取模式提供的一種 hint（提示/屬性），用來告訴儲存控制器某段資料的預期使用行為（例如：存取頻率、延遲敏感度）。