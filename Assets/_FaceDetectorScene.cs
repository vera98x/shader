namespace OpenCvSharp.Demo
{
	using System;
	using UnityEngine;
	using System.Collections.Generic;
	using UnityEngine.UI;
	using OpenCvSharp;

	public class _FaceDetectorScene : WebCamera
	{
		public TextAsset faces;
		public TextAsset eyes;
		public TextAsset shapes;
		public GameObject object_move;
		public GameObject canvas_show;

		private FaceProcessorLive<WebCamTexture> processor;

		/// <summary>
		/// Default initializer for MonoBehavior sub-classes
		/// </summary>
		protected override void Awake()
		{
			base.Awake();
			base.forceFrontalCamera = true; // we work with frontal cams here, let's force it for macOS s MacBook doesn't state frontal cam correctly

			byte[] shapeDat = shapes.bytes;
			

			processor = new FaceProcessorLive<WebCamTexture>();
			processor.Initialize(faces.text, eyes.text, shapes.bytes);

			// data stabilizer - affects face rects, face landmarks etc.
			processor.DataStabilizer.Enabled = true;        // enable stabilizer
			processor.DataStabilizer.Threshold = 2.0;       // threshold value in pixels
			processor.DataStabilizer.SamplesCount = 2;      // how many samples do we need to compute stable data

			// performance data - some tricks to make it work faster
			processor.Performance.Downscale = 256;          // processed image is pre-scaled down to N px by long side
			processor.Performance.SkipRate = 0;             // we actually process only each Nth frame (and every frame for skipRate = 0)
		}

		/// <summary>
		/// Per-frame video capture processor
		/// </summary>
		protected override bool ProcessTexture(WebCamTexture input, ref Texture2D output)
		{
			// detect everything we're interested in
			processor.ProcessTexture(input, TextureParameters);

			// mark detected objects
			List<OpenCvSharp.Rect> faceBounds = processor.MarkDetected();
			if(faceBounds.Count > 0)
			{
				//print("Check");
				//print(faceBounds[0]);
				OpenCvSharp.Rect foundFace = faceBounds[0];
				//print(foundFace.TopLeft);
				//print(foundFace.BottomRight);
				//print("-------");
				int diff_x = foundFace.TopLeft.X+(foundFace.BottomRight.X-foundFace.TopLeft.X)/2; // find middle of the head

				object_move.transform.position = new Vector3((diff_x)/-1.57f, (foundFace.TopLeft.Y)/-2.3f, 2);
			}

			// processor.Image now holds data we'd like to visualize
			output = Unity.MatToTexture(processor.Image, output);   // if output is valid texture it's buffer will be re-used, otherwise it will be re-created
			canvas_show.GetComponent<MeshRenderer>().material.mainTexture = Unity.MatToTexture(processor.Image, output);
			return true;
		}
	}
}