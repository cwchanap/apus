# App Coverage 50% Design

## Context

The local coverage baseline was measured from `build/TestResults/LocalCoverage.xcresult` after running the `apus-ci` scheme with coverage enabled, `apusTests` selected, and `apusUITests` skipped.

- Unit-test result: 245 passed, 0 failed, 2 skipped.
- Full report coverage: 34.0%, because the report includes test code.
- App target coverage: `apus.app` is 15.6% with 3,344 covered lines out of 21,486 executable lines.
- Test target coverage: `apusTests.xctest` is 94.0%, with 6,193 covered lines out of 6,586 executable lines.

The current aggregate coverage is inflated by test-target coverage. Excluding test code will make the app-target gap visible and is the intended reporting behavior.

## Goals

- Exclude the test projects from Codecov coverage reporting:
  - `apusTests/**`
  - `apusUITests/**`
- Raise local `apus.app` target coverage to at least 50%.
- Keep the coverage increase meaningful by covering app behavior rather than hiding broad app paths.
- Preserve the existing unit-test command shape used by CI: `apus-ci`, coverage enabled, unit tests selected, UI tests skipped.

## Non-Goals

- Do not pursue the earlier 65% target in this slice.
- Do not add real camera, photo-library, or physical-device dependent tests.
- Do not require UI tests to improve app-target coverage.
- Do not broadly exclude app source folders from Codecov just to hit the number.
- Do not perform unrelated architecture cleanup.

## Approach

Add a repo-level Codecov configuration that ignores test-only paths. The existing GitHub Actions workflow already creates an `xcresult`, converts coverage to Cobertura with `xcresultparser`, and uploads that file to Codecov, so the configuration change should focus on Codecov path filtering rather than replacing the export flow.

Raise app-target coverage with focused unit tests around deterministic app code. The first implementation pass should target high-line, low-coverage files where behavior can be exercised without hardware:

- Result presentation and formatting code, including shared result components and individual result views.
- Settings and storage-limit UI behavior that can be validated through view models, bindings, or extracted pure helpers.
- Timeline row, filter, and grouping presentation behavior where the model/view-model contract is already testable.
- Preview overlays and coordinate/visibility logic that can be tested with fixed rectangles, image sizes, and mock detections.
- Mock managers and protocol default behaviors that are currently compiled into the app target but mostly uncovered.

Production seams may be introduced only when they make existing behavior testable with low risk. Good seams are small pure functions, formatting helpers, or dependency injection points that preserve current public behavior. Large SwiftUI rewrites or manager refactors are outside this design unless coverage inspection shows they are necessary to reach 50%.

## Coverage Measurement

The acceptance metric is local `apus.app` target coverage from the generated `xcresult`, not the aggregate report percentage. The implementation should continue to verify with an Xcode coverage run and inspect the target-level report.

Expected verification shape:

```bash
xcodebuild \
  -project apus.xcodeproj \
  -scheme apus-ci \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -enableCodeCoverage YES \
  -only-testing:apusTests \
  -skip-testing:apusUITests \
  -resultBundlePath build/TestResults/LocalCoverage.xcresult \
  -derivedDataPath build/DerivedData \
  test
```

Then inspect `build/TestResults/LocalCoverage.xcresult` and confirm `apus.app` is at least 50.0%.

## Risks And Constraints

- The app target has many SwiftUI files with large executable-line counts, so reaching 50% from 15.6% requires substantial coverage gain.
- SwiftUI body coverage can be brittle if tests assert implementation detail. Prefer stable behavior helpers and existing model/view-model contracts.
- Vision, Core ML, camera, and photo-library code can require simulator services, permissions, or bundled models. Tests for those areas should use mocks, fixed images, or pure transformation logic.
- Codecov path filtering must not hide app source files. The intent is only to remove test-project source from the uploaded coverage accounting.

## Acceptance Criteria

- `.codecov.yml` or equivalent Codecov configuration excludes `apusTests/**` and `apusUITests/**`.
- Local coverage verification passes with all unit tests green.
- Target-level coverage for `apus.app` is at least 50.0%.
- The final report distinguishes app-target coverage from aggregate coverage.
- Any production changes made for coverage are small, behavior-preserving, and covered by tests.
