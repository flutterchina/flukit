[中文简体](README.md)|English
# flukit

*flukit* is a **Flutter UI Kit**。

## Notice

**This project is in development now and  there is no release or stable version。 We do not recommend that you use it in production .**

## Contribution&Run demo

### **Project dirs**

```
flukit

	--lib           //demo dir
	--package_src
		--lib
			--src  //widget dir
```

### **Run demo**

```
flutter run
```

### **Notice of submission**

If you add a new widget，please follow these rules:

1. Add more details as possible in comments.
2. Add demo in demo dir.

## Widgets

| Widget                                     | Description                                                  | Related                                                      |
| ------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| AfterLayout                                | A widget can retrieve its render object after layout.        |                                                              |
| AccurateSizedBox                           | A box with a specified size for its child. It is similar to [SizedBox],  but the difference is SizedBox pass the constraints received from its parent to its child, but [AccurateSizedBox] not. | SizedBox                                                     |
| AnimatedRotationBox                        | Rotates child forever                                        |                                                              |
| DoneWidget                                 | Done tip widget                                              |                                                              |
| GradientButton<br />ElevatedGradientButton | Button with gradient colors                                  |                                                              |
| GradientCircularProgressIndicator          | A circular progress indicator with gradient effect.          |                                                              |
| HitTestBlocker                             | A blocker by which we can intercept hit test flow.           |                                                              |
| KeepAliveWrapper                           | KeepAliveWrapper can keep the item(s) of scrollview alive.   |                                                              |
| LeftRightBox                               | A widget which supports left-right layout algorithm。        |                                                              |
| LayoutLogPrint                             | A helper widget which can print constraints information in debug mode. |                                                              |
| LogListenerScope                           | A stateful widget to listen redirected log events.           | VerticalLogPanel、LogPanel                                   |
| VerticalLogPanel                           | A widget to show redirected logs from `print`, which will divide the available display space vertically into two areas, and display the logs  below. | LogPanel、LogListenerScope                                   |
| LogPanel                                   | A widget to show redirected logs from `print`.               | VerticalLogPanel、LogListenerScope                           |
| PullRefreshScope                           | A widget provides pull refresh scope. Typically, the child is a [CustomScrollView]. | SliverPullRefreshIndicator                                   |
| SliverPullRefreshIndicator                 | A indicator for PullRefreshScope.                            | PullRefreshScope                                             |
| QuickScrollbar                             | A quick scrollbar for scroll views.                          |                                                              |
| Swiper                                     | A  scrollable list that works page by page automatically or manually,  and it also support loop playbacks. | RectangleSwiperIndicator、CircleSwiperIndicator、SwiperController |
| ScaleView                                  | Scale the child from `minScale` to  `maxScale` . support scale  and double click gesture. |                                                              |
| SliverFlexibleHeader                       | A sliver to provide a flexible header that its height can expand when user continue  dragging over scroll . Typically as the first child  of  [CustomScrollView]. | SliverPullRefreshIndicator                                   |
| SliverPersistentHeaderToBox                | A sliver like [SliverPersistentHeader], the difference is [SliverPersistentHeaderToBox]   can contain a box widget and use the height of its child directly. |                                                              |
| SliverHeaderDelegate                       | Delegate helper  for [SliverPersistentHeader]                |                                                              |
| SlideTransitionX                           | Animates the position of a widget relative to its normal position  ignoring the animation direction(always slide along one direction). Typically, is used in combination with [AnimatedSwitcher]. |                                                              |
| OverflowWithTranslateBox                   | A widget that:  1. imposes different constraints on its child than it gets from   its parent, possibly allowing the child to overflow the parent.  2.  apply translate to its child (specified by [offset]). |                                                              |
| TurnBox                                    | Animates the rotation of a widget when [turns]  is changed.  |                                                              |
| WaterMark                                  | A widget that paints watermark.                              | TextWaterMarkPainter、StaggerTextWaterMarkPainter            |

## Tools

| Tools                      | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| ExtraInfoBoxConstraints    | A box constraints with extra information.                    |
| SafeValueNotifier          | Make sure notifying is safe during build/layout/paint phase. |
| RenderObjectAnimationMixin | Animation scheduling helper for RenderObject.                |
