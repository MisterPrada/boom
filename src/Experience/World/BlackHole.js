import * as THREE from 'three'
import Experience from '../Experience.js'
import sunVertexShader from '../Shaders/BlackHole/vertex.glsl'
import sunFragmentShader from '../Shaders/BlackHole/fragment.glsl'
import gsap from "gsap";
import Debug from "@experience/Utils/Debug.js";

export default class BlackHole {
    experience = new Experience()
    debug = Debug.getInstance()

    constructor() {

        this.scene = this.experience.scene
        this.time = this.experience.time
        this.sizes = this.experience.sizes
        this.camera = this.experience.camera
        this.renderer = this.experience.renderer.instance
        this.timeline = this.experience.timeline

        this.parameters = {
            position: new THREE.Vector3(0, 4.5, -4.7),
            scale: new THREE.Vector3(0.5, 0.5, 0.5),
            width: 100.0,
            height: 100.0,
        }


        this.setModel()
        this.setDebug()
    }

    setModel() {
        this.geometry = new THREE.PlaneGeometry( this.parameters.width, this.parameters.height, 128, 128 );
        this.material = new THREE.ShaderMaterial( {
            //wireframe: true,
            //side: THREE.DoubleSide,
            depthWrite: false,
            depthTest: false,
            //vertexColors: true,
            transparent: true,
            //blending: THREE.AdditiveBlending,
            uniforms:
                {
                    uTime: { value: 0 },
                    uResolution: { value: new THREE.Vector2(128 * this.sizes.pixelRatio, 128 * this.sizes.pixelRatio) },
                },
            vertexShader: sunVertexShader,
            fragmentShader: sunFragmentShader
        } );
        this.hellPortal = new THREE.Mesh( this.geometry, this.material );
        this.hellPortal.position.copy(this.parameters.position);
        this.hellPortal.scale.copy(this.parameters.scale);
        this.hellPortal.renderOrder = 6;

        this.scene.add(this.hellPortal);
    }

    setScaleAnimation() {

    }

    resize()
    {

    }

    update() {
        this.material.uniforms.uTime.value = this.time.elapsed * 0.1
        this.hellPortal.lookAt(this.camera.instance.position)
    }

    setDebug() {
        // Debug
        if(this.debug.active)
        {
            this.debugFolder = this.debug.panel.addFolder( 'BlackHole' );
            this.debugFolder.add(this.hellPortal.position, 'x').min(-100).max(100).step(0.1).name('position x')
            this.debugFolder.add(this.hellPortal.position, 'y').min(-100).max(100).step(0.1).name('position y')
            this.debugFolder.add(this.hellPortal.position, 'z').min(-100).max(100).step(0.1).name('position z')

            this.debugFolder.add(this.hellPortal.scale, 'x').min(-100).max(100).step(0.1).name('scale x')
            this.debugFolder.add(this.hellPortal.scale, 'y').min(-100).max(100).step(0.1).name('scale y')
            this.debugFolder.add(this.hellPortal.scale, 'z').min(-100).max(100).step(0.1).name('scale z')
        }
    }
}
