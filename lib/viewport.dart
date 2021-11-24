import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class FixedVerticalResolutionViewport extends Viewport {
  late double effectiveHeight;

  final Vector2 _scaledSize = Vector2.zero();
  Vector2 get scaledSize => _scaledSize.clone();

  final Vector2 _resizeOffset = Vector2.zero();
  Vector2 get resizeOffset => _resizeOffset.clone();

  late double _scale;
  double get scale => _scale;

  /// The matrix used for scaling and translating the canvas
  final Matrix4 _transform = Matrix4.identity();

  /// The Rect that is used to clip the canvas
  late Rect _clipRect;

  FixedVerticalResolutionViewport(this.effectiveHeight);

  @override
  void resize(Vector2 newCanvasSize) {
    canvasSize = newCanvasSize.clone();

    _scale = canvasSize!.y / effectiveHeight;

    _scaledSize
      ..setFrom(effectiveSize)
      ..scale(_scale);
    _resizeOffset
      ..setFrom(canvasSize!)
      ..sub(_scaledSize)
      ..scale(0.5);

    _clipRect = _resizeOffset & _scaledSize;

    _transform
      ..setIdentity()
      ..translate(_resizeOffset.x, _resizeOffset.y)
      ..scale(_scale, _scale, 1);
  }

  @override
  void render(Canvas c, void Function(Canvas) renderGame) {
    c
      ..save()
      ..clipRect(_clipRect)
      ..transform(_transform.storage);
    renderGame(c);
    c.restore();
  }

  @override
  Vector2 projectVector(Vector2 viewportCoordinates) {
    return (viewportCoordinates * _scale)..add(_resizeOffset);
  }

  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    return (screenCoordinates - _resizeOffset)..scale(1 / _scale);
  }

  @override
  Vector2 scaleVector(Vector2 viewportCoordinates) {
    return viewportCoordinates * scale;
  }

  @override
  Vector2 unscaleVector(Vector2 screenCoordinates) {
    return screenCoordinates / scale;
  }

  @override
  Vector2 get effectiveSize => Vector2(canvasSize!.x / _scale, effectiveHeight);
}
