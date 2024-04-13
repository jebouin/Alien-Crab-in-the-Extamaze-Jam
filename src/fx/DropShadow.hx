package fx;

import h2d.filter.Shader;

class DropShadow extends Shader<InternalShader> {
	public function new(r:Float, intensity:Float) {
		var s = new InternalShader();
		s.radius = r;
		s.intensity = intensity;
		super(s);
	}

	override function draw(ctx:h2d.RenderContext, t:h2d.Tile):h2d.Tile {
		shader.texelSize.set(1 / t.width, 1 / t.height);
		return super.draw(ctx, t);
	}
}


private class InternalShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;
		@param var texelSize : Vec2;
		@param var radius : Float;
		@param var intensity : Float;

		function fragment() {
			var uv = calculatedUV;
			var curColor : Vec4 = texture.get(uv);
            pixelColor = curColor;
            if(curColor.a < 1) {
                var u : Vec4 = texture.get(uv - radius * vec2(0, texelSize.y));
                var l : Vec4 = texture.get(uv - radius * vec2(texelSize.x, 0));
                var ul : Vec4 = texture.get(uv - radius * vec2(texelSize.x, texelSize.y));
				var dark = (u.a > 0 ? intensity : 0) + (l.a > 0 ? intensity : 0) + (ul.a > 0 ? intensity : 0);
				pixelColor = vec4(vec3(0, 0, 0), dark);
            }
		}
	};
}