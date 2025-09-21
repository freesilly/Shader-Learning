using UnityEngine;
[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    #region Material properties
    public Material material = null;

    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int TextureWidth
    {
        get
        {
            return textureWidth;
        }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color BackgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.red;
    public Color CircleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;
    public float BlurFactor
    {
        get
        {
            return m_blurFactor;
        }
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion
    private Texture2D m_generatedTexture = null;

    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer = null)
            {
                Debug.LogWarning("No material attached to the object");
                return;
            }
            material = renderer.sharedMaterial;
        }

        _UpdateMaterial();
    }

    private Color _MixColor(Color color0, Color color1, float mixFactor) 
    {
		Color mixColor = Color.white;
		mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
		mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
		mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
		mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
		return mixColor;
	}

    private void _UpdateMaterial()
    {
        if (material != null)
        {
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D result = new Texture2D(textureWidth, textureWidth);

        float circleInterval = textureWidth / 4.0f;

        float radius = textureWidth / 10.0f;

        float edgeBlur = 1.0f / blurFactor;

        for(int w =0; w < textureWidth; w++)
        {
            for(int h = 0; h < textureWidth; h++)
            {
                Color pixel = BackgroundColor;

                for(int i=0; i<3; i++)
                {
                    for(int j=0; j<3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        Color color = _MixColor(CircleColor, new Color(pixel.r, pixel.g, pixel.b, 0), Mathf.SmoothStep(0, 1, dist * edgeBlur));
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                result.SetPixel(w, h, pixel);
            }
        }
        result.Apply();
        return result;
    }
}
