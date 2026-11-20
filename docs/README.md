# Tài liệu SmartTravel

Rà soát ngày 16/11/2026. Tài liệu được chia theo mục đích đọc; báo cáo theo chủ đề giữ bằng chứng của từng đợt thực hiện, không thay cho trạng thái hiện tại.

## Bắt đầu từ đâu

| Bạn cần | Tài liệu |
| --- | --- |
| Hiểu hệ thống đã có gì | [Tổng quan mã nguồn](codebase-summary.md) |
| Biết việc nào đã triển khai, việc nào chưa nghiệm thu | [Trạng thái yêu cầu](planning/requirements-status.md) |
| Xem thứ tự công việc và tiêu chí đóng mốc | [Kế hoạch hoàn thiện](planning/completion-plan.md) |
| Hiểu các tầng và hợp đồng dữ liệu | [Kiến trúc hệ thống](architecture/system-architecture.md) |
| Hiểu bảng, trường, giá, giờ mở cửa và snapshot | [Schema hiện hành](architecture/database-schema.md) và [ERD đầy đủ](architecture/erd/smarttravel.mmd) |
| Sửa mã hoặc chạy kiểm tra | [Quy chuẩn](development/code-standards.md), [quy trình](development/agent-workflow.md), [hướng dẫn kiểm thử](development/testing-runbook.md) |

## Cấu trúc

```text
docs/
  README.md                  Mục lục và cách sử dụng
  codebase-summary.md        Tổng quan triển khai hiện tại
  architecture/              Kiến trúc, schema và ERD
  development/               Quy chuẩn, quy trình và kiểm thử
  planning/                  Trạng thái yêu cầu và kế hoạch nghiệm thu
  reports/
    README.md                Hướng dẫn đọc báo cáo theo chủ đề
    features/                Kết quả triển khai từng luồng sản phẩm
    engineering/             Hợp đồng dữ liệu và baseline database
    experience/              Ngôn ngữ, UI và khả năng tiếp cận
    history/                 Đánh giá ban đầu và các snapshot cũ
    evidence/                Bằng chứng lịch sử cần giữ nguyên
```

## Báo cáo theo chủ đề

Đọc [mục lục báo cáo](reports/README.md) để tìm theo câu hỏi nghiệp vụ, không cần biết mã mốc triển khai.

| Nhóm | Nơi đọc |
| --- | --- |
| Chức năng sản phẩm | [Tài khoản, catalog, lịch trình, đánh giá, quản trị và thời tiết](reports/README.md#chức-năng-sản-phẩm) |
| Hợp đồng và database | [Dữ liệu dùng chung và baseline](reports/README.md#dữ-liệu-và-trải-nghiệm-dùng-chung) |
| Ngôn ngữ, UI và accessibility | [Trải nghiệm dùng chung](reports/README.md#dữ-liệu-và-trải-nghiệm-dùng-chung) |
| Đánh giá ban đầu và dấu vết thay đổi | [Tài liệu lịch sử](reports/README.md#lịch-sử-tham-khảo) |

## Cách đọc và cập nhật

- Các file trong `architecture/` mô tả mô hình hiện có. SQL Flyway và mã nguồn là căn cứ khi kiểm tra cấu trúc, kiểu dữ liệu và hành vi thực thi; khác biệt với yêu cầu phải được ghi rõ, không tự coi mã nguồn đã đáp ứng yêu cầu.
- [PRD](../tasks/prd-smarttravel.md) và [user stories](../tasks/smarttravel-user-stories.md) nằm trong `tasks/`. Phạm vi đã điều chỉnh và phần chưa đáp ứng được ghi tập trung ở [trạng thái yêu cầu](planning/requirements-status.md).
- `planning/requirements-status.md` là nơi đọc tiến độ hiện tại. `completion-plan.md` giữ mã việc và tiêu chí nghiệm thu, không phải danh sách khẳng định tất cả đã hoàn thành.
- Báo cáo trong `reports/` tổng hợp theo chủ đề và ghi rõ thời điểm của từng kết quả kiểm chứng. Các snapshot cũ nằm ở `reports/history/`. Không cộng số test giữa các đợt và không dùng widget test/browser fixture để chứng minh E2E trên thiết bị thật.
- Sau thay đổi, cập nhật trang mô tả chịu ảnh hưởng, trạng thái và báo cáo tương ứng; tránh chèn nhiều đoạn “cập nhật mới” trái nhau vào đầu tài liệu.
- Khi di chuyển tài liệu, sửa liên kết tương đối và đường dẫn trong README/hướng dẫn agent. Không sửa checksum lịch sử hoặc migration để làm cho tài liệu trông đồng bộ.
