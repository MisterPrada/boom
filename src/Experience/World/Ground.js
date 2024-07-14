import * as THREE from 'three'
import Model from './Abstracts/Model.js'
import Experience from '../Experience.js'
import Debug from '../Utils/Debug.js'
import State from "../State.js";
import Materials from "../Materials/Materials.js";

import { LoopSubdivision } from 'three-subdivide';

import vertexShader from '../Shaders/PhongMaterial/vertex.glsl'

export default class Ground extends Model {
    experience = Experience.getInstance()
    debug = Debug.getInstance()
    state = State.getInstance()
    materials = Materials.getInstance()
    scene = experience.scene
    time = experience.time
    camera = experience.camera.instance
    renderer = experience.renderer.instance
    resources = experience.resources
    container = new THREE.Group();

    u_Progress = 0

    constructor() {
        super()

        this.setTextures()
        //this.setBasicGround()
        this.setModel()
        this.setDebug()
    }

    setTextures() {
        this.groundColorTexture = this.resources.items.groundColorTexture
        this.groundColorTexture.wrapS = THREE.RepeatWrapping
        this.groundColorTexture.wrapT = THREE.RepeatWrapping
        this.groundColorTexture.colorSpace = THREE.SRGBColorSpace
        this.groundColorTexture.repeat.set( 1, 1 )
        this.groundColorTexture.needsUpdate = true

        this.groundNormalTexture = this.resources.items.groundNormalTexture
        this.groundNormalTexture.wrapS = THREE.RepeatWrapping
        this.groundNormalTexture.wrapT = THREE.RepeatWrapping
        this.groundNormalTexture.colorSpace = THREE.SRGBColorSpace
        this.groundNormalTexture.needsUpdate = true

        this.groundDisplacementTexture = this.resources.items.groundDisplacementTexture
        this.groundDisplacementTexture.wrapS = THREE.RepeatWrapping
        this.groundDisplacementTexture.wrapT = THREE.RepeatWrapping
        this.groundDisplacementTexture.colorSpace = THREE.SRGBColorSpace
        this.groundDisplacementTexture.needsUpdate = true
    }

    setBasicGround() {
        // ground brown color

        this.basicGround = new THREE.Mesh(
            new THREE.PlaneGeometry( 1000, 1000, 100, 100 ),
            new THREE.MeshPhongMaterial( {
                //color: 0x000000,
                side: THREE.BackSide,
                map: this.groundColorTexture,
                //displacementMap: this.groundDisplacementTexture,
            } )
        )
        this.basicGround.rotation.x = Math.PI / 2
        this.basicGround.position.y = -0.1
        this.scene.add( this.basicGround )

    }

    setModel() {
        this.model = this.resources.items.groundModel
        //this.model.scale.set(0.01, 0.01, 0.01);
        //this.model.rotation.x = Math.PI / 2;

        // set matrix rotation Math.PI / 2;
        this.model.applyMatrix4(new THREE.Matrix4().makeRotationX(- Math.PI / 2));


        const iterations = 2;

        const params = {
            split:          true,       // optional, default: true
            uvSmooth:       false,      // optional, default: false
            preserveEdges:  false,      // optional, default: false
            flatOnly:       true,      // optional, default: false
            maxTriangles:   Infinity,   // optional, default: Infinity
        };


        this.model.traverse((child) => {
            if (child.isMesh) {
                child.geometry = LoopSubdivision.modify(child.geometry, iterations, params);
                child.frustumCulled = false
                this.material = child.material
            }
        })

        this.material.map = this.groundColorTexture
        this.material.normalMap = this.groundNormalTexture
        //this.material.displacementMap = this.groundNormalTexture
        //this.material.wireframe = true


        this.material.onBeforeCompile = (shader) => {
            shader.vertexShader = vertexShader

            this.material.uniforms = shader.uniforms
            this.material.uniforms.u_Time =  new THREE.Uniform(0)
            this.material.uniforms.u_Progress = new THREE.Uniform(this.u_Progress)

        }


        this.container.add(this.model);
        this.scene.add(this.container);
    }

    resize() {

    }

    setDebug() {
        if ( !this.debug.active ) return

        this.debugFolder = this.debug.panel.addFolder( 'ground' );
        this.debugFolder.add( this, 'u_Progress', 0.0, 1, 0.001 ).onChange( () => {
            this.material.uniforms.u_Progress.value = this.u_Progress
        })


        //this.debug.createDebugTexture( this.resources.items.displacementTexture )
    }

    update( deltaTime ) {
        if(this.material.uniforms) {
            this.material.uniforms.u_Time.value = this.time.elapsed
        }
    }

}
