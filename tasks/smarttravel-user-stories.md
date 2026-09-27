# SmartTravel User Stories

## Epic 1: Tạo chuyến đi

### US-01: Tạo lịch trình từ thông tin chuyến đi
As a traveler, I want to enter destination, travel dates, group size, budget, and preferences, so that I can get a personalized itinerary quickly.

Acceptance Criteria:
- Given I fill in all required fields with valid data, when I click “Create itinerary”, then the system starts generating a plan and shows a progress indicator.
- Given I leave required fields empty or invalid, when I submit, then the system highlights the invalid fields and blocks generation.
- Given I input a budget, when the plan is generated, then the itinerary includes an estimated cost breakdown.

### US-02: Tùy chọn nhịp độ và sở thích
As a traveler, I want to choose pace, interests, and constraints, so that the trip plan matches my preferences and energy level.

Acceptance Criteria:
- Given I select a pace (relaxed, balanced, packed), when the itinerary is generated, then the suggestions reflect that pace.
- Given I add interests or constraints, when I generate a plan, then those items are considered in the itinerary.
- Given I have conflicting preferences, when the system cannot satisfy all, then it explains the conflict and offers alternatives.

## Epic 2: Xem và đánh giá lịch trình

### US-03: Xem lịch trình theo ngày
As a traveler, I want to review a day-by-day itinerary with time, place, and cost, so that I can assess whether it is realistic and suitable.

Acceptance Criteria:
- Given I open the itinerary, when I view a day, then I can see activities ordered by time.
- Given each activity, when I inspect it, then I can see title, time, duration, location, and estimated cost.
- Given there is a time conflict, when I view the plan, then the warning is clearly displayed.

### US-04: Xem chi phí tổng và phân bổ ngân sách
As a budget-conscious traveler, I want to see the total estimated cost and category breakdown, so that I can adjust the plan without overspending.

Acceptance Criteria:
- Given the itinerary is created, when I open the budget view, then I see total estimate and category-level cost.
- Given some items have missing cost info, when I review the budget, then they are labeled as estimated or excluded.
- Given I modify the plan, when the revision is saved, then the total budget updates automatically.

### US-05: Nhận cảnh báo về lịch trình quá tải
As a traveler, I want to know if the itinerary is too packed or has travel gaps, so that I can avoid an unrealistic schedule.

Acceptance Criteria:
- Given there are overlapping activities, when the itinerary is generated, then a warning is displayed.
- Given travel time is insufficient between activities, when I review the plan, then a warning is shown.
- Given the schedule is too dense, when I read the summary, then the system highlights the issue and suggests reducing items.

## Epic 3: Chỉnh sửa lịch trình

### US-06: Điều chỉnh lịch trình bằng câu lệnh tự nhiên
As a traveler, I want to request changes in plain language, so that I can refine the trip without rebuilding it manually.

Acceptance Criteria:
- Given I enter a request like “make it cheaper” or “add rest day”, when I submit, then the relevant activity or day is adjusted.
- Given the request conflicts with existing constraints, when the system cannot satisfy both, then it explains the conflict and proposes options.
- Given the update fails, when I try to apply it, then the previous version still remains available.

### US-07: Xem lịch sử phiên bản / hoàn tác
As a traveler, I want to see revisions and restore a previous itinerary version, so that I can compare options safely.

Acceptance Criteria:
- Given I make multiple updates, when I open version history, then I can see the timeline of changes.
- Given I choose a previous version, when I restore it, then the itinerary reverts to that version.
- Given a version is restored, when I review it, then all previous constraints remain consistent.

## Epic 4: Lưu trữ và chia sẻ

### US-08: Lưu lịch trình
As a traveler, I want to save my itinerary, so that I can come back later and continue planning.

Acceptance Criteria:
- Given I have a valid itinerary, when I click Save, then it is stored successfully.
- Given I reopen the app later, when I access my saved itinerary, then I can view my previous plan.
- Given the save fails, when I try again, then the system shows a recoverable error message.

### US-09: Chia sẻ lịch trình dạng read-only
As a traveler, I want to share a read-only itinerary link, so that my companions can review the plan without changing it.

Acceptance Criteria:
- Given I generate a share link, when a user opens it, then they can view the itinerary but cannot edit it.
- Given I revoke the link, when someone tries to open it, then access is denied.
- Given the shared link is expired or invalid, when opened, then the system shows a clear message.

## Epic 5: Tin cậy và báo cáo

### US-10: Báo cáo mục không chính xác
As a traveler, I want to report an incorrect or unreliable itinerary item, so that I can improve trust in the plan.

Acceptance Criteria:
- Given I open an itinerary item, when I choose “Report issue”, then I can select a predefined reason.
- Given I submit a report, when it is accepted, then the system confirms receipt without removing the plan.
- Given a report is submitted, when the item is reviewed, then it is tracked for follow-up.

### US-11: Xác định nguồn và độ tin cậy
As a traveler, I want each activity to show where it came from and whether it is verified, so that I know how much I can trust it.

Acceptance Criteria:
- Given an activity has a source, when I inspect it, then the UI shows the source and reliability label.
- Given source data is missing or unverified, when I view the activity, then it is labeled as “needs confirmation”.
- Given a source is outdated or questionable, when I review the item, then the system warns the user.
