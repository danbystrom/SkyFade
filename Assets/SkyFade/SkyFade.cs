using UnityEngine;
using UnityEngine.Experimental.Rendering;

[RequireComponent(typeof(Camera))]
public class SkyFade : MonoBehaviour
{

    [Range(1f, 100f)]
    public float distanceFactor = 10;

    private Camera _skyboxCamera;
    private RenderTexture _skyboxRenderTexture;
    private Material _bleningMaterial;

    private Quaternion _lastRotation;
    private int _lastScreenWidth;
    private int _lastScreenHeight;

    void Awake()
    {
        _bleningMaterial = new Material(Shader.Find("Hidden/SkyFadeShader"));

        var skyboxCameraGameObject = new GameObject("SkyFade Camera Carrier")
        {
            transform =
            {
                parent = transform,
                localPosition = Vector3.zero,
                localRotation = Quaternion.identity
            }
        };

        var myCamera = GetComponent<Camera>();

        _skyboxCamera = skyboxCameraGameObject.AddComponent<Camera>();
        _skyboxCamera.CopyFrom(myCamera);
        _skyboxCamera.cullingMask = 0;
        _skyboxCamera.enabled = false;

        myCamera.clearFlags = CameraClearFlags.Depth;
        myCamera.depthTextureMode = DepthTextureMode.Depth;

        createRenderTexture();

        var oldSkybox = GetComponent<Skybox>();
        if (oldSkybox != null && oldSkybox.enabled)
        {
            var newSkybox = _skyboxCamera.gameObject.AddComponent<Skybox>();
            newSkybox.material = oldSkybox.material;
            oldSkybox.enabled = false;
        }

        OnValidate();
    }

    private void OnValidate()
    {
        if (_bleningMaterial == null)
            return;
        distanceFactor = Mathf.Clamp(distanceFactor, 1f, 100f);
        _bleningMaterial.SetFloat("_DistanceThreshold", distanceFactor / 100000);
    }

    private void createRenderTexture()
    {
        _lastScreenWidth = Screen.width;
        _lastScreenHeight = Screen.height;
        _skyboxRenderTexture = new RenderTexture(_lastScreenWidth / 2, _lastScreenHeight / 2,
            GraphicsFormat.B8G8R8A8_UNorm, GraphicsFormat.D32_SFloat_S8_UInt, 0);
        _skyboxCamera.targetTexture = _skyboxRenderTexture;
        _bleningMaterial.SetTexture("_Skybox", _skyboxRenderTexture);
        _lastRotation.x++;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_lastScreenWidth != Screen.width || _lastScreenHeight != Screen.height)
        {
            Destroy(_skyboxRenderTexture);
            createRenderTexture();
            _lastRotation.x++;;
        }

        if (transform.rotation != _lastRotation)
        {
            _skyboxCamera.Render();
            _lastRotation = transform.rotation;
        }

        _bleningMaterial.SetTexture("_Screen", source);
        Graphics.Blit(source, destination, _bleningMaterial);
    }
}